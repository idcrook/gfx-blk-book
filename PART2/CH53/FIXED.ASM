; 386-specific fixed point routines.
; Tested with TASM
ROUNDING_ON     equ     1     ;1 for rounding, 0 for no rounding
                              ;no rounding is faster, rounding is
                              ; more accurate
ALIGNMENT        equ    2
      .model     small
      .386
      .code
;=====================================================================
; Multiplies two fixed-point values together.
; C near-callable as:
;     Fixedpoint FixedMul(Fixedpoint M1, Fixedpoint M2);
;     Fixedpoint FixedDiv(Fixedpoint Dividend, Fixedpoint Divisor);
FMparms struc
            dw   2 dup(?)      ;return address & pushed BP
M1          dd   ?
M2          dd   ?
FMparms     ends
            align   ALIGNMENT
            public  _FixedMul
_FixedMul       proc    near
        push    bp
        mov     bp,sp
        mov     eax,[bp+M1]
        imul    dword ptr [bp+M2] ;multiply
if ROUNDING_ON
        add     eax,8000h       ;round by adding 2^(-17)
        adc     edx,0           ;whole part of result is in DX
endif ;ROUNDING-ON
        shr     eax,16          ;put the fractional part in AX
        pop     bp
        ret
_FixedMul       endp
;=====================================================================
; Divides one fixed-point value by another.
; C near-callable as:
;     Fixedpoint FixedDiv(Fixedpoint Dividend, Fixedpoint Divisor);
FDparms struc
           dw    2 dup(?)       ;return address & pushed BP
Dividend   dd    ?
Divisor    dd    ?
FDparms    ends
      align ALIGNMENT
public        _FixedDiv
_FixedDiv       proc    near
        push    bp
        mov     bp,sp

if ROUNDING_ON
        sub     cx,cx           ;assume positive result
        mov     eax,[bp+Dividend]
        and     eax,eax         ;positive dividend?
        jns     FDP1            ;yes
        inc     cx              ;mark it's a negative dividend
        neg     eax             ;make the dividend positive
FDP1:   sub     edx,edx         ;make it a 64-bit dividend, then shift
                                ; left 16 bits so that result will be
                                ; in EAX
        rol     eax,16          ;put fractional part of dividend in
                                ; high word of EAX
        mov     dx,ax           ;put whole part of dividend in DX
        sub     ax,ax           ;clear low word of EAX
        mov     ebx,dword ptr [bp+Divisor]
        and     ebx,ebx         ;positive divisor?
        jns     FDP2            ;yes
        dec     cx              ;mark it's a negative divisor
        neg     ebx             ;make divisor positive
FDP2:   div     ebx             ;divide
        shr     ebx,1           ;divisor/2, minus 1 if the divisor is
        adc     ebx,0           ; even
        dec     ebx
        cmp     ebx,edx         ;set Carry if remainder is at least
        adc     eax,0           ; half as large as the divisor, then
                                ; use that to round up if necessary
        and     cx,cx           ;should the result be made negative?
        jz      FDP3            ;no
        neg     eax             ;yes, negate it
FDP3:
else ;  !ROUNDING-ON
        mov     edx,[bp+Dividend]
        sub     eax,eax
        shrd    eax,edx,16       ;position so that result ends up
        sar     edx,16           ; in EAX
        idiv    dword ptr [bp+Divisor]
endif ;ROUNDING-ON
        shld    edx,eax,16       ;whole part of result in DX;
                                 ; fractional part is already in AX
        pop      bp
        ret
_FixedDiv       endp
;=====================================================================
; Returns the sine and cosine of an angle.
; C near-callable as:
;void CosSin(TAngle Angle, Fixedpoint *Cos, Fixedpoint *);

align ALIGNMENT
CosTable label dword
include costable.inc

SCparms struc
            dw    2 dup(?)    ;return address & pushed BP
Angle       dw    ?           ;angle to calculate sine & cosine for
Cos         dw    ?           ;pointer to cos destination
Sin         dw    ?           ;pointer to sin destination
SCparms ends

   align ALIGNMENT
   public _CosSin
_CosSin proc near
     push  bp                  ;preserve stack frame
     mov   bp,sp               ;set up local stack frame

     mov   bx,[bp].Angle
     and   bx,bx               ;make sure angle's between 0 and 2*pi
jns  CheckInRange
MakePos:;less than 0, so make it positive
     add    bx,360*10
     js     MakePos
     jmp    short CheckInRange

align ALIGNMENT
MakeInRange:                   ;make sure angle is no more than 2*pi
     sub   bx,360*10
CheckInRange:
cmp   bx,360*10
jg    MakeInRange

      cmp  bx,180*10        ;figure out which quadrant
      ja   BottomHalf       ;quadrant 2 or 3
      cmp  bx,90*10         ;quadrant 0 or 1
      ja   Quadrant1
                            ;quadrant 0
      shl   bx,2
      mov   eax,CosTable[bx] ;look up sine
      neg   bx              ;sin(Angle) = cos(90-Angle)
      mov   edx,CosTable[bx + (90*10*4)] ;look up cosine
      jmp   short CSDone

      align  ALIGNMENT
Quadrant1:
      neg    bx
      add    bx,180*10       ;convert to angle between 0 and 90
      shl    bx,2
      mov    eax,CosTable[bx] ;look up cosine
      neg    eax             ;negative in this quadrant
      neg    bx              ;sin(Angle) = cos(90-Angle)
      mov    edx,CosTable[bx + (90*10*4)] ;look up cosine
      jmp    short CSDone

      align  ALIGNMENT
BottomHalf:                ;quadrant 2 or 3
      neg     bx
      add     bx,360*10    ;convert to angle between 0 and 180
      cmp     bx,90*10     ;quadrant 2 or 3
      ja      Quadrant2
                           ;quadrant 3
      shl      bx, 2
      mov      eax,CosTable[bx]     ;look up cosine
      neg      bx              ;sin(Angle) = cos(90-Angle)
      mov      edx,CosTable[(90*10*4) + bx] ;look up sine
      neg      edx          ;negative in this quadrant
      jmp      short CSDone

      align  ALIGNMENT
Quadrant2:
     neg     bx
     add     bx,180*10      ;convert to angle between 0 and 90
     shl     bx,2
     mov     eax,CosTable[bx] ;look up cosine
     neg     eax          ;negative in this quadrant
     neg     bx           ;sin(Angle) = cos(90-Angle)
     mov     edx,CosTable[(90*10*4) + bx] ;look up sine
     neg     edx             ;negative in this quadrant
CSDone:
     mov      bx,[bp].Cos
     mov      [bx],eax
     mov      bx,[bp].Sin
     mov      [bx],edx

     pop      bp;restore stack frame
ret
_CosSin endp
;=====================================================================
; Matrix multiplies Xform by SourceVec, and stores the result in
; DestVec. Multiplies a 4x4 matrix times a 4x1 matrix; the result
; is a 4x1 matrix. Cheats by assuming the W coord is 1 and the
; bottom row of the matrix is 0 0 0 1, and doesn't bother to set
; the W coordinate of the destination.
; C near-callable as:
;     void XformVec(Xform WorkingXform, Fixedpoint *SourceVec,
;          Fixedpoint *DestVec);
;
; This assembly code is equivalent to this C code:
;   int i;
;
;   for (i=0; i<3; i++)
;      DestVec[i] = FixedMul(WorkingXform[i][0], SourceVec[0]) +
;     FixedMul(WorkingXform[i][1], SourceVec[1]) +
;     FixedMul(WorkingXform[i][2], SourceVec[2]) +
;     WorkingXform[i][3];   /* no need to multiply by W = 1 */

XVparms struc
               dw    2 dup(?)   ;return address & pushed BP
WorkingXform   dw    ?          ;pointer to transform matrix
SourceVec      dw    ?          ;pointer to source vector
DestVec        dw    ?          ;pointer to destination vector
XVparms       ends

    align  ALIGNMENT
    public _XformVec
_XformVec   proc   near
    push    bp                  ;preserve stack frame
    mov     bp,sp               ;set up local stack frame
    push    si                  ;preserve register variables
    push    di

    mov     si,[bp].WorkingXform  ;SI points to xform matrix
    mov     bx,[bp].SourceVec    ;BX points to source vector
    mov     di,[bp].DestVec    ;DI points to dest vector

soff=0
doff=0
    REPT 3                     ;do once each for dest X, Y, and Z
    mov    eax,[si+soff]       ;column 0 entry on this row
    imul   dword ptr [bx]      ;xform entry times source X entry
if ROUNDING_ON
    add    eax,8000h           ;round by adding 2^(-17)
    adc    edx,0               ;whole part of result is in DX
endif ;ROUNDING-ON
    shrd   eax,edx,16;shift the result back to 16.16 form
    mov    ecx,eax             ;set running total

    mov    eax,[si+soff+4]     ;column 1 entry on this row
    imul   dword ptr [bx+4]    ;xform entry times source Y entry
if ROUNDING_ON
    add    eax,8000h           ;round by adding 2^(-17)
    adc    edx,0               ;whole part of result is in DX
endif ;ROUNDING-ON
    shrd   eax,edx,16          ;shift the result back to 16.16 form
    add    ecx,eax             ;running total for this row

    mov    eax,[si+soff+8]     ;column 2 entry on this row
    imul   dword ptr [bx+8]    ;xform entry times source Z entry
if ROUNDING_ON
    add    eax,8000h           ;round by adding 2^(-17)
    adc    edx,0               ;whole part of result is in DX
endif ;ROUNDING-ON
    shrd   eax,edx,16          ;shift the result back to 16.16 form
    add    ecx,eax             ;running total for this row

    add    ecx,[si+soff+12]    ;add in translation
    mov[di+doff],ecx          ;save the result in the dest vector
soff=soff+16
doff=doff+4
ENDM

pop di;restore register variables
pop si
pop bp;restore stack frame
ret
_XformVec endp
;=====================================================================
; Matrix multiplies SourceXform1 by SourceXform2 and stores the
; result in DestXform. Multiplies a 4x4 matrix times a 4x4 matrix;
; the result is a 4x4 matrix. Cheats by assuming the bottom row of
; each matrix is 0 0 0 1, and doesn't bother to set the bottom row
; of the destination.
; C near-callable as:
;       void ConcatXforms(Xform SourceXform1, Xform SourceXform2,
;               Xform DestXform)
;
; This assembly code is equivalent to this C code:
;   int i, j;
;
;   for (i=0; i<3; i++) {
;      for (j=0; j<3; j++)
;         DestXform[i][j] =
;               FixedMul(SourceXform1[i][0], SourceXform2[0][j]) +
;               FixedMul(SourceXform1[i][1], SourceXform2[1][j]) +
;               FixedMul(SourceXform1[i][2], SourceXform2[2][j]);
;      DestXform[i][3] =
;            FixedMul(SourceXform1[i][0], SourceXform2[0][3]) +
;            FixedMul(SourceXform1[i][1], SourceXform2[1][3]) +
;            FixedMul(SourceXform1[i][2], SourceXform2[2][3]) +
;            SourceXform1[i][3];
;   }

CXparms struc
             dw     2 dup(?)         ;return address & pushed BP
SourceXform1 dw     ?                ;pointer to first source xform matrix
SourceXform2  dw    ?                ;pointer to second source xform matrix
DestXform     dw    ?                ;pointer to destination xform matrix
CXparms       ends

       align  ALIGNMENT
       public _ConcatXforms
_ConcatXforms    proc  near
     push   bp                     ;preserve stack frame
     mov    bp,sp                  ;set up local stack frame
     push   si                     ;preserve register variables
     push   di

     mov    bx,[bp].SourceXform2    ;BX points to xform2 matrix
     mov    si,[bp].SourceXform1    ;SI points to xform1 matrix
     mov    di,[bp].DestXform       ;DI points to dest xform matrix

roff=0                          ;row offset
      REPT 3                    ;once for each row
coff=0                          ;column offset
      REPT 3                    ;once for each of the first 3 columns,
                                ; assuming 0 as the bottom entry (no
; translation)
      mov     eax,[si+roff]     ;column 0 entry on this row
      imul    dword ptr [bx+coff];times row 0 entry in column
if ROUNDING_ON
      add     eax,8000h        ;round by adding 2^(-17)
      adc     edx,0            ;whole part of result is in DX
endif ;ROUNDING-ON
       shrd    eax,edx,16       ;shift the result back to 16.16 form
       mov     ecx,eax          ;set running total

       mov     eax,[si+roff+4]  ;column 1 entry on this row
       imul    dword ptr [bx+coff+16];times row 1 entry in col
if ROUNDING_ON
       add    eax,8000h         ;round by adding 2^(-17)
       adc    edx,0             ;whole part of result is in DX
endif ;ROUNDING-ON
       shrd   eax,edx,16        ;shift the result back to 16.16 form
       add    ecx,eax           ;running total

       mov    eax,[si+roff+8]   ;column 2 entry on this row
       imul   dword ptr [bx+coff+32];times row 2 entry in col
if ROUNDING_ON
       add    eax,8000h         ;round by adding 2^(-17)
       adc    edx,0             ;whole part of result is in DX
endif ;ROUNDING-ON
       shrd   eax,edx,16        ;shift the result back to 16.16 form
       add    ecx,eax           ;running total

       mov[di+coff+roff],ecx    ;save the result in dest matrix
coff=coff+4                     ;point to next col in xform2 & dest
ENDM
                               ;now do the fourth column, assuming
                               ; 1 as the bottom entry, causing
                               ; translation to be performed
       mov     eax,[si+roff]   ;column 0 entry on this row
       imul    dword ptr [bx+coff]   ;times row 0 entry in column
if ROUNDING_ON
       add     eax,8000h       ;round by adding 2^(-17)
       adc     edx,0           ;whole part of result is in DX
endif ;ROUNDING-ON
       shrd    eax,edx,16      ;shift the result back to 16.16 form
       mov     ecx,eax         ;set running total

       mov     eax,[si+roff+4] ;column 1 entry on this row
       imul    dword ptr [bx+coff+16];times row 1 entry in col
if ROUNDING_ON
        add    eax,8000h       ;round by adding 2^(-17)
        adc    edx,0           ;whole part of result is in DX
endif ;ROUNDING-ON
        shrd   eax,edx,16      ;shift the result back to 16.16 form
       add     ecx,eax         ;running total

       mov     eax,[si+roff+8]  ;column 2 entry on this row
       imul    dword ptr [bx+coff+32];times row 2 entry in col
if ROUNDING_ON
       add    eax,8000h         ;round by adding 2^(-17)
       adc    edx,0             ;whole part of result is in DX
endif ;ROUNDING-ON
       shrd   eax,edx,16        ;shift the result back to 16.16 form
       add    ecx,eax           ;running total

       add    ecx,[si+roff+12]  ;add in translation

       mov    [di+coff+roff],ecx ;save the result in dest matrix
coff=coff+4                ;point to next col in xform2 & dest

roff=roff+16                ;point to next col in xform2 & dest
       ENDM

       pop di;restore register variables
       pop si
       pop bp;restore stack frame
       ret
_ConcatXforms endp
end
