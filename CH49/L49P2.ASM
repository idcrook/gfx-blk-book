; Mode X (320x240, 256 colors) display memory to display memory masked copy
; routine. Works on all VGAs. Uses approach of reading 4 pixels at a time from
; source into latches, then writing latches to destination, using Map Mask
; register to perform masking. Copies up to but not including column at
; SourceEndX and row at SourceEndY. No clipping is performed. Results are not
; guaranteed if source and destination overlap. C near-callable as:
;
;    void CopyScreenToScreenMaskedX(int SourceStartX,
;       int SourceStartY, int SourceEndX, int SourceEndY,
;       int DestStartX, int DestStartY, MaskedImage * Source,
;       unsigned int DestPageBase, int DestBitmapWidth);

SC_INDEX equ    03c4h   ;Sequence Controller Index register port
MAP_MASK equ    02h     ;index in SC of Map Mask register
GC_INDEX equ    03ceh   ;Graphics Controller Index register port
BIT_MASK equ    08h     ;index in GC of Bit Mask register
SCREEN_SEG equ  0a000h  ;segment of display memory in mode X

parms   struc
                dw 2 dup (?) ;pushed BP and return address
SourceStartX    dw ?         ;X coordinate of upper left corner of source
SourceStartY    dw ?         ;Y coordinate of upper left corner of source
SourceEndX      dw ?         ;X coordinate of lower right corner of source
                             ; (the column at SourceEndX is not copied)
SourceEndY      dw ?         ;Y coordinate of lower right corner of source
                             ; (the row at SourceEndY is not copied)
DestStartX      dw ?         ;X coordinate of upper left corner of dest
DestStartY      dw ?         ;Y coordinate of upper left corner of dest
Source          dw ?         ;pointer to MaskedImage struct for source
                             ; which source resides
DestPageBase    dw ?         ;base offset in display memory of page in
                             ; which dest resides
DestBitmapWidth dw ?        ;# of pixels across dest bitmap (must be multiple of 4)
parms   ends

SourceNextScanOffset equ -2   ;local storage for distance from end of
                              ; one source scan line to start of next
DestNextScanOffset  equ -4    ;local storage for distance from end of
                              ; one dest scan line to start of next
RectAddrWidth       equ -6    ;local storage for address width of rectangle
RectHeight          equ -8    ;local storage for height of rectangle
SourceBitmapWidth   equ -10   ;local storage for width of source bitmap
                              ; (in addresses)
STACK_FRAME_SIZE    equ 10
MaskedImage         struc
 Alignments         dw  4 dup(?) ;pointers to AlignedMaskedImages for the
                                 ; 4 possible destination image alignments
MaskedImage     ends
AlignedMaskedImage      struc
 ImageWidth     dw      ?   ;image width in addresses (also mask width in bytes)
 ImagePtr       dw      ?   ;offset of image bitmap in display memory
 MaskPtr        dw      ?   ;pointer to mask bitmap in DS
AlignedMaskedImage      ends
        .model  small
        .code
        public  _CopyScreenToScreenMaskedX
_CopyScreenToScreenMaskedX proc    near
        push    bp      ;preserve caller's stack frame
        mov     bp,sp   ;point to local stack frame
        sub     sp,STACK_FRAME_SIZE ;allocate space for local vars
        push    si      ;preserve caller's register variables
        push    di

        cld
        mov     dx,GC_INDEX     ;set the bit mask to select all bits
        mov     ax,00000h+BIT_MASK ; from the latches and none from
        out     dx,ax           ; the CPU, so that we can write the
                                ; latch contents directly to memory
        mov     ax,SCREEN_SEG   ;point ES to display memory
        mov     es,ax
        mov     ax,[bp+DestBitmapWidth]
        shr     ax,1            ;convert to width in addresses
        shr     ax,1
        mul     [bp+DestStartY] ;top dest rect scan line
        mov     di,[bp+DestStartX]
        mov     si,di
        shr     di,1             ;X/4 = offset of first dest rect pixel in
        shr     di,1             ; scan line
        add     di,ax            ;offset of first dest rect pixel in page
        add     di,[bp+DestPageBase] ;offset of first dest rect pixel in display
                                 ; memory. now look up the image that's
                                 ; aligned to match left-edge alignment
                                 ; of destination
        and     si,3             ;DestStartX modulo 4
        mov     cx,si            ;set aside alignment for later
        shl     si,1             ;prepare for word look-up
        mov     bx,[bp+Source] ;point to source MaskedImage structure
        mov     bx,[bx+Alignments+si] ;point to AlignedMaskedImage
                                 ; struc for current left edge alignment
        mov     ax,[bx+ImageWidth] ;image width in addresses
        mov     [bp+SourceBitmapWidth],ax ;remember image width in addresses
        mul     [bp+SourceStartY] ;top source rect scan line
        mov     si,[bp+SourceStartX]
        shr     si,1             ;X/4 = address of first source rect pixel in
        shr     si,1             ; scan line
        add     si,ax            ;offset of first source rect pixel in image
        mov     ax,si
        add     si,[bx+MaskPtr] ;point to mask offset of first mask pixel in DS
        mov     bx,[bx+ImagePtr] ;offset of first source rect pixel
        add     bx,ax            ; in display memory

        mov     ax,[bp+SourceStartX] ;calculate # of addresses across
        add     ax,cx            ; rect, shifting if necessary to
        add     cx,[bp+SourceEndX]   ; account for alignment
        cmp     cx,ax
        jle     CopyDone         ;skip if 0 or negative width
        add     cx,3
        and     ax,not 011b
        sub     cx,ax
        shr     cx,1
        shr     cx,1             ;# of addresses across rectangle to copy
        mov     ax,[bp+SourceEndY]
        sub     ax,[bp+SourceStartY]  ;AX = height of rectangle
        jle     CopyDone        ;skip if 0 or negative height
        mov     [bp+RectHeight],ax
        mov     ax,[bp+DestBitmapWidth]
        shr     ax,1            ;convert to width in addresses
        shr     ax,1
        sub     ax,cx ;distance from end of one dest scan line to start of next
        mov     [bp+DestNextScanOffset],ax
        mov     ax,[bp+SourceBitmapWidth] ;width in addresses
        sub     ax,cx ;distance from end of source scan line to start of next
        mov     [bp+SourceNextScanOffset],ax
        mov     [bp+RectAddrWidth],cx ;remember width in addresses

        mov     dx,SC_INDEX
        mov     al,MAP_MASK
        out     dx,al           ;point SC Index register to Map Mask
        inc     dx              ;point to SC Data register
CopyRowsLoop:
        mov     cx,[bp+RectAddrWidth] ;width across
CopyScanLineLoop:
        lodsb                   ;get the mask for this four-pixel set
                                ; and advance the mask pointer
        out     dx,al           ;set the mask
        mov     al,es:[bx]      ;load the latches with four-pixel set from source
        mov     es:[di],al      ;copy the four-pixel set to the dest
        inc     bx              ;advance the source pointer
        inc     di              ;advance the destination pointer
        dec     cx              ;count off four-pixel sets
        jnz     CopyScanLineLoop

        mov     ax,[bp+SourceNextScanOffset]
        add     si,ax           ;point to the start of
        add     bx,ax           ; the next source, mask,
        add     di,[bp+DestNextScanOffset] ; and dest lines
        dec     word ptr [bp+RectHeight] ;count down scan lines
        jnz     CopyRowsLoop
CopyDone:
        mov     dx,GC_INDEX+1   ;restore the bit mask to its default,
        mov     al,0ffh         ; which selects all bits from the CPU
        out     dx,al           ; and none from the latches (the GC
                                ; Index still points to Bit Mask)
        pop     di              ;restore caller's register variables
        pop     si
        mov     sp,bp           ;discard storage for local variables
        pop     bp              ;restore caller's stack frame
        ret
_CopyScreenToScreenMaskedX endp
        end
