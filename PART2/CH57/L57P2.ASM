; Draws all pixels in the specified scan line, with the pixel colors
; taken from the specified texture map.  Uses approach of pre-stepping
; 1/2 pixel into the source image and rounding to the nearest source
; pixel at each step, so that texture maps will appear reasonably similar
; at all angles.  This routine is specific to 320-pixel-wide planar
; (non-chain4) 256-color modes, such as mode X, which is a planar
; (non-chain4) 256-color mode with a resolution of 320x240.
; C near-callable as: 
;   void ScanOutLine(EdgeScan * LeftEdge, EdgeScan * RightEdge);
; Tested with TASM 3.0.

SC_INDEX     equ    03c4h     ;Sequence Controller Index
MAP_MASK     equ    02h       ;index in SC of Map Mask register
SCREEN_SEG   equ    0a000h    ;segment of display memory in mode X
SCREEN_WIDTH equ    80        ;width of screen in bytes from one scan line
                              ; to the next

        .model  small
        .data
        extrn   _TexMapBits:word, _TexMapWidth:word, _DestY:word
        extrn   _CurrentPageBase:word, _ClipMinX:word
        extrn   _ClipMinY:word, _ClipMaxX:word, _ClipMaxY:word

; Describes the current location and stepping, in both the source and
; the destination, of an edge. Mirrors structure in DRAWTEXP.C.
EdgeScan struc
Direction      dw    ?        ;through edge list; 1 for a right edge (forward
                              ; through vertex list), -1 for a left edge (backward
                              ; through vertex list)
RemainingScans dw    ?        ;height left to scan out in dest
CurrentEnd     dw    ?        ;vertex # of end of current edge
SourceX        dd    ?        ;X location in source for this edge
SourceY        dd    ?        ;Y location in source for this edge
SourceStepX    dd    ?        ;X step in source for Y step in dest of 1
SourceStepY    dd    ?        ;Y step in source for Y step in dest of 1
                              ;variables used for all-integer Bresenham's-type
                              ; X stepping through the dest, needed for precise
                              ; pixel placement to avoid gaps
DestX          dw    ?        ;current X location in dest for this edge
DestXIntStep   dw    ?        ;whole part of dest X step per scan-line Y step
DestXDirection dw    ?        ;-1 or 1 to indicate which way X steps (left/right)
DestXErrTerm   dw    ?        ;current error term for dest X stepping
DestXAdjUp     dw    ?        ;amount to add to error term per scan line move
DestXAdjDown   dw    ?        ;amount to subtract from error term when the
                              ; error term turns over
EdgeScan ends

Parms   struc
               dw    2 dup(?) ;return address & pushed BP
LeftEdge       dw    ?        ;pointer to EdgeScan structure for left edge
RightEdge      dw    ?        ;pointer to EdgeScan structure for right edge
Parms   ends

;Offsets from BP in stack frame of local variables.
lSourceX       equ   -4       ;current X coordinate in source image
lSourceY       equ   -8       ;current Y coordinate in source image
lSourceStepX   equ   -12      ;X step in source image for X dest step of 1
lSourceStepY   equ   -16      ;Y step in source image for X dest step of 1
lXAdvanceByOne equ   -18      ;used to step source pointer 1 pixel
                              ; incrementally in X
lXBaseAdvance  equ   -20      ;use to step source pointer minimum number of
                              ; pixels incrementally in X
lYAdvanceByOne equ   -22      ;used to step source pointer 1 pixel
                              ; incrementally in Y
lYBaseAdvance  equ   -24      ;use to step source pointer minimum number of
                              ; pixels incrementally in Y
LOCAL_SIZE     equ    24      ;total size of local variables
        .code
        extrn   _FixedMul:near, _FixedDiv:near
        align   2
ToScanDone:
        jmp     ScanDone
        public  _ScanOutLine
        align   2
_ScanOutLine    proc    near
        push    bp              ;preserve caller's stack frame
        mov     bp,sp           ;point to our stack frame
        sub     sp,LOCAL_SIZE   ;allocate space for local variables
        push    si              ;preserve caller's register variables
        push    di
; Nothing to do if destination is fully X clipped.
        mov     di,[bp].RightEdge
        mov     si,[di].DestX
        cmp     si,[_ClipMinX]
        jle     ToScanDone      ;right edge is to left of clip rect, so done
        mov     bx,[bp].LeftEdge
        mov     dx,[bx].DestX
        cmp     dx,[_ClipMaxX]
        jge     ToScanDone      ;left edge is to right of clip rect, so done
        sub     si,dx           ;destination fill width
        jle     ToScanDone      ;null or negative full width, so done

        mov     ax,word ptr [bx].SourceX        ;initial source X coordinate
        mov     word ptr [bp].lSourceX,ax
        mov     ax,word ptr [bx].SourceX+2
        mov     word ptr [bp].lSourceX+2,ax

        mov     ax,word ptr [bx].SourceY        ;initial source Y coordinate
        mov     word ptr [bp].lSourceY,ax
        mov     ax,word ptr [bx].SourceY+2
        mov     word ptr [bp].lSourceY+2,ax
; Calculate source steps that correspond to each 1-pixel destination X step
; (across the destination scan line).
        push    si              ;push dest X width, in fixedpoint form
        sub     ax,ax
        push    ax              ;push 0 as fractional part of dest X width
        mov     ax,word ptr [di].SourceX
        sub     ax,word ptr [bp].lSourceX       ;low word of source X width
        mov     dx,word ptr [di].SourceX+2
        sbb     dx,word ptr [bp].lSourceX+2     ;high word of source X width
        push    dx              ;push source X width, in fixedpoint form
        push    ax
        call    _FixedDiv       ;scale source X width to dest X width
        add     sp,8            ;clear parameters from stack
        mov     word ptr [bp].lSourceStepX,ax   ;remember source X step for
        mov     word ptr [bp].lSourceStepX+2,dx ; 1-pixel destination X step
        mov     cx,1            ;assume source X advances non-negative
        and     dx,dx           ;which way does source X advance?
        jns     SourceXNonNeg   ;non-negative
        neg     cx              ;negative
        cmp     ax,0            ;is the whole step exactly an integer?
        jz      SourceXNonNeg   ;yes
        inc     dx              ;no, truncate to integer in the direction of
                                ; 0, because otherwise we'll end up with a
                                ; whole step of 1-too-large magnitude
SourceXNonNeg:
        mov     [bp].lXAdvanceByOne,cx  ;amount to add to source pointer to
                                        ; move by one in X
        mov     [bp].lXBaseAdvance,dx   ;minimum amount to add to source
                                        ; pointer to advance in X each time
                                        ; the dest advances one in X
        push    si              ;push dest Y height, in fixedpoint form
        sub     ax,ax
        push    ax              ;push 0 as fractional part of dest Y height
        mov     ax,word ptr [di].SourceY
        sub     ax,word ptr [bp].lSourceY       ;low word of source Y height
        mov     dx,word ptr [di].SourceY+2
        sbb     dx,word ptr [bp].lSourceY+2     ;high word of source Y height
        push    dx              ;push source Y height, in fixedpoint form
        push    ax
        call    _FixedDiv       ;scale source Y height to dest X width
        add     sp,8            ;clear parameters from stack
        mov     word ptr [bp].lSourceStepY,ax   ;remember source Y step for
        mov     word ptr [bp].lSourceStepY+2,dx ; 1-pixel destination X step
        mov     cx,[_TexMapWidth] ;assume source Y advances non-negative
        and     dx,dx           ;which way does source Y advance?
        jns     SourceYNonNeg   ;non-negative
        neg     cx              ;negative
        cmp     ax,0            ;is the whole step exactly an integer?
        jz      SourceYNonNeg   ;yes
        inc     dx              ;no, truncate to integer in the direction of
                                ; 0, because otherwise we'll end up with a
                                ; whole step of 1-too-large magnitude
SourceYNonNeg:
        mov     [bp].lYAdvanceByOne,cx  ;amount to add to source pointer to
                                        ; move by one in Y
        mov     ax,[_TexMapWidth]       ;minimum distance skipped in source
        imul    dx                      ; image bitmap when Y steps (ignoring
        mov     [bp].lYBaseAdvance,ax   ; carry from the fractional part)
; Advance 1/2 step in the stepping direction, to space scanned pixels evenly
; between the left and right edges. (There's a slight inaccuracy in dividing
; negative numbers by 2 by shifting rather than dividing, but the inaccuracy
; is in the least significant bit, and we'll just live with it.)
        mov     ax,word ptr [bp].lSourceStepX
        mov     dx,word ptr [bp].lSourceStepX+2
        sar     dx,1
        rcr     ax,1
        add     word ptr [bp].lSourceX,ax
        adc     word ptr [bp].lSourceX+2,dx

        mov     ax,word ptr [bp].lSourceStepY
        mov     dx,word ptr [bp].lSourceStepY+2
        sar     dx,1
        rcr     ax,1
        add     word ptr [bp].lSourceY,ax
        adc     word ptr [bp].lSourceY+2,dx
; Clip right edge if necessary.
        mov     si,[di].DestX
        cmp     si,[_ClipMaxX]
        jl      RightEdgeClipped
        mov     si,[_ClipMaxX]
RightEdgeClipped:
; Clip left edge if necssary
        mov     bx,[bp].LeftEdge
        mov     di,[bx].DestX
        cmp     di,[_ClipMinX]
        jge     LeftEdgeClipped
; Left clipping is necessary; advance the source accordingly
        neg     di
        add     di,[_ClipMinX]  ;ClipMinX - DestX
                                ;first, advance the source in X
        push    di              ;push ClipMinX - DestX, in fixedpoint form
        sub     ax,ax
        push    ax              ;push 0 as fractional part of ClipMinX-DestX
        push    word ptr [bp].lSourceStepX+2
        push    word ptr [bp].lSourceStepX
        call    _FixedMul       ;total source X stepping in clipped area
        add     sp,8            ;clear parameters from stack
        add     word ptr [bp].lSourceX,ax;step the source X past clipping
        adc     word ptr [bp].lSourceX+2,dx
                                ;now advance the source in Y
        push    di              ;push ClipMinX - DestX, in fixedpoint form
        sub     ax,ax
        push    ax              ;push 0 as fractional part of ClipMinX-DestX
        push    word ptr [bp].lSourceStepY+2
        push    word ptr [bp].lSourceStepY
        call    _FixedMul       ;total source Y stepping in clipped area
        add     sp,8            ;clear parameters from stack
        add     word ptr [bp].lSourceY,ax;step the source Y past clipping
        adc     word ptr [bp].lSourceY+2,dx
        mov     di,[_ClipMinX]  ;start X coordinate in dest after clipping
LeftEdgeClipped:
; Calculate actual clipped destination drawing width.
        sub     si,di
; Scan across the destination scan line, updating the source image position
; accordingly.
; Point to the initial source image pixel, adding 0.5 to both X and Y so that
; we can truncate to integers from now on but effectively get rounding.
        add     word ptr [bp].lSourceY,8000h;add 0.5
        mov     ax,word ptr [bp].lSourceY+2
        adc     ax,0
        mul     [_TexMapWidth]   ;initial scan line in source image
        add     word ptr [bp].lSourceX,8000h;add 0.5
        mov     bx,word ptr [bp].lSourceX+2 ;offset into source scan line
        adc     bx,ax            ;initial source offset in source image
        add     bx,[_TexMapBits] ;DS:BX points to the initial image pixel
; Point to initial destination pixel.
        mov     ax,SCREEN_SEG
        mov     es,ax
        mov     ax,SCREEN_WIDTH
        mul     [_DestY] ;offset of initial dest scan line
        mov     cx,di   ;initial destination X
        shr     di,1
        shr     di,1    ;X/4 = offset of pixel in scan line
        add     di,ax   ;offset of pixel in page
        add     di,[_CurrentPageBase] ;offset of pixel in display memory
;ES:DI now points to the first destination pixel

        and     cl,011b ;CL = pixel's plane
        mov     al,MAP_MASK
        mov     dx,SC_INDEX
        out     dx,al   ;point the SC Index register to the Map Mask
        mov     al,11h  ;one plane bit in each nibble, so we'll get carry
                        ; automatically when going from plane 3 to plane 0
        shl     al,cl   ;set the bit for the first pixel's plane to 1
; If source X step is negative, change over to working with non-negative
; values.
        cmp     word ptr [bp].lXAdvanceByOne,0
        jge     SXStepSet
        neg     word ptr [bp].lSourceStepX
        not     word ptr [bp].lSourceX
SXStepSet:
; If source Y step is negative, change over to working with non-negative
; values.
        cmp     word ptr [bp].lYAdvanceByOne,0
        jge     SYStepSet
        neg     word ptr [bp].lSourceStepY
        not     word ptr [bp].lSourceY
SYStepSet:
; At this point:
;       AL = initial pixel's plane mask
;       BX = pointer to initial image pixel
;       SI = # of pixels to fill
;       DI = pointer to initial destination pixel
        mov     dx,SC_INDEX+1   ;point to SC Data; Index points to Map Mask
TexScanLoop:
; Set the Map Mask for this pixel's plane, then draw the pixel.
        out     dx,al
        mov     ah,[bx]         ;get image pixel
        mov     es:[di],ah      ;set image pixel
; Point to the next source pixel.
        add     bx,[bp].lXBaseAdvance   ;advance the minimum # of pixels in X
        mov     cx,word ptr [bp].lSourceStepX
        add     word ptr [bp].lSourceX,cx;step the source X fractional part
        jnc     NoExtraXAdvance          ;didn't turn over; no extra advance
        add     bx,[bp].lXAdvanceByOne   ;did turn over; advance X one extra
NoExtraXAdvance:
        add     bx,[bp].lYBaseAdvance;advance the minimum # of pixels in Y
        mov     cx,word ptr [bp].lSourceStepY
        add     word ptr [bp].lSourceY,cx;step the source Y fractional part
        jnc     NoExtraYAdvance;didn't turn over; no extra advance
        add     bx,[bp].lYAdvanceByOne;did turn over; advance Y one extra
NoExtraYAdvance:
; Point to the next destination pixel, by cycling to the next plane, and
; advancing to the next address if the plane wraps from 3 to 0.
        rol     al,1
        adc     di,0
; Continue if there are any more dest pixels to draw.
        dec     si
        jnz     TexScanLoop
ScanDone:
        pop     di              ;restore caller's register variables
        pop     si
        mov     sp,bp           ;deallocate local variables
        pop     bp              ;restore caller's stack frame
        ret
_ScanOutLine    endp
        end

