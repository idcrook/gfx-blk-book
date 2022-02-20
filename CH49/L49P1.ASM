; Mode X (320x240, 256 colors) system memory-to-display memory masked copy
; routine. Not particularly fast; images for which performance is critical
; should be stored in off-screen memory and copied to screen via latches. Works
; on all VGAs. Copies up to but not including column at SourceEndX and row at
; SourceEndY. No clipping is performed. Mask and source image are both byte-
; per-pixel, and must be of same widths and reside at same coordinates in their
; respective bitmaps. Assembly code tested with TASM C near-callable as:
;
;    void CopySystemToScreenMaskedX(int SourceStartX,
;       int SourceStartY, int SourceEndX, int SourceEndY,
;       int DestStartX, int DestStartY, char * SourcePtr,
;       unsigned int DestPageBase, int SourceBitmapWidth,
;       int DestBitmapWidth, char * MaskPtr);

SC_INDEX equ    03c4h   ;Sequence Controller Index register port
MAP_MASK equ    02h     ;index in SC of Map Mask register
SCREEN_SEG equ  0a000h  ;segment of display memory in mode X

parms   struc
        dw      2 dup (?) ;pushed BP and return address
SourceStartX dw ?         ;X coordinate of upper left corner of source
                          ; (source is in system memory)
SourceStartY dw ?         ;Y coordinate of upper left corner of source
SourceEndX   dw ?         ;X coordinate of lower right corner of source
                          ; (the column at EndX is not copied)
SourceEndY   dw ?         ;Y coordinate of lower right corner of source
                          ; (the row at EndY is not copied)
DestStartX   dw ?         ;X coordinate of upper left corner of dest
                          ; (destination is in display memory)
DestStartY   dw ?         ;Y coordinate of upper left corner of dest
SourcePtr    dw ?         ;pointer in DS to start of bitmap which source resides
DestPageBase dw ?         ;base offset in display memory of page in
                          ; which dest resides
SourceBitmapWidth   dw ?  ;# of pixels across source bitmap (also must
                          ; be width across the mask)
DestBitmapWidth     dw ?  ;# of pixels across dest bitmap (must be multiple of 4)
MaskPtr             dw ?  ;pointer in DS to start of bitmap in which mask
                          ; resides (byte-per-pixel format, just like the source
                          ; image; 0-bytes mean don't copy corresponding source
                          ; pixel, 1-bytes mean do copy)
parms   ends

RectWidth equ   -2      ;local storage for width of rectangle
RectHeight equ  -4      ;local storage for height of rectangle
LeftMask equ    -6      ;local storage for left rect edge plane mask
STACK_FRAME_SIZE equ 6
        .model  small
        .code
        public  _CopySystemToScreenMaskedX
_CopySystemToScreenMaskedX proc    near
        push    bp                       ;preserve caller's stack frame
        mov     bp,sp                    ;point to local stack frame
        sub     sp,STACK_FRAME_SIZE      ;allocate space for local vars
        push    si                       ;preserve caller's register variables
        push    di

        mov     ax,SCREEN_SEG            ;point ES to display memory
        mov     es,ax
        mov     ax,[bp+SourceBitmapWidth]
        mul     [bp+SourceStartY]    ;top source rect scan line
        add     ax,[bp+SourceStartX]
        mov     bx,ax
        add     ax,[bp+SourcePtr]    ;offset of first source rect pixel
        mov     si,ax                    ; in DS
        add     bx,[bp+MaskPtr]      ;offset of first mask pixel in DS

        mov     ax,[bp+DestBitmapWidth]
        shr     ax,1                     ;convert to width in addresses
        shr     ax,1
        mov     [bp+DestBitmapWidth],ax ;remember address width
        mul     [bp+DestStartY]         ;top dest rect scan line
        mov     di,[bp+DestStartX]
        mov     cx,di
        shr     di,1                        ;X/4 = offset of first dest rect pixel in
        shr     di,1                        ; scan line
        add     di,ax                       ;offset of first dest rect pixel in page
        add     di,[bp+DestPageBase]    ;offset of first dest rect pixel
                                            ; in display memory
        and     cl,011b                        ;CL = first dest pixel's plane
        mov     al,11h                      ;upper nibble comes into play when plane wraps
                                            ; from 3 back to 0
        shl     al,cl                       ;set the bit for the first dest pixel's plane
        mov     [bp+LeftMask],al        ; in each nibble to 1

        mov     ax,[bp+SourceEndX]      ;calculate # of pixels across
        sub     ax,[bp+SourceStartX]    ; rect
        jle     CopyDone                    ;skip if 0 or negative width
        mov     [bp+RectWidth],ax
        sub     word ptr [bp+SourceBitmapWidth],ax
                                            ;distance from end of one source scan line
                                            ;to start of next
        mov     ax,[bp+SourceEndY]
        sub     ax,[bp+SourceStartY]    ;height of rectangle
        jle     CopyDone                    ;skip if 0 or negative height
        mov     [bp+RectHeight],ax
        mov     dx,SC_INDEX                 ;point to SC Index register
        mov     al,MAP_MASK
        out     dx,al                      ;point SC Index reg to the Map Mask
        inc     dx                         ;point DX to SC Data reg
CopyRowsLoop:
        mov     al,[bp+LeftMask]
        mov     cx,[bp+RectWidth]
        push    di                         ;remember the start offset in the dest
CopyScanLineLoop:
        cmp     byte ptr [bx],0            ;is this pixel mask-enabled?
        jz      MaskOff                    ;no, so don't draw it
                                           ;yes, draw the pixel
        out     dx,al                      ;set the plane for this pixel
        mov     ah,[si]                    ;get the pixel from the source
        mov     es:[di],ah                 ;copy the pixel to the screen
MaskOff:
        inc     bx                         ;advance the mask pointer
        inc     si                         ;advance the source pointer
        rol     al,1                       ;set mask for next pixel's plane
        adc     di,0                       ;advance destination address only when
                                           ;wrapping from plane 3 to plane 0
        loop    CopyScanLineLoop
        pop     di                         ;retrieve the dest start offset
        add     di,[bp+DestBitmapWidth];point to the start of the
                                           ; next scan line of the dest
        add     si,[bp+SourceBitmapWidth] ;point to the start of the
                                           ;next scan line of the source
        add     bx,[bp+SourceBitmapWidth] ;point to the start of the
                                           ;next scan line of the mask
        dec     word ptr [bp+RectHeight] ;count down scan lines
        jnz     CopyRowsLoop
CopyDone:
        pop     di                          ;restore caller's register variables
        pop     si
        mov     sp,bp                       ;discard storage for local variables
        pop     bp                          ;restore caller's stack frame
        ret
_CopySystemToScreenMaskedX endp
        end
