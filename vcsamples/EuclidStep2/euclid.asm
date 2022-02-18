; Copyright (c) Microsoft Corporation.  All rights reserved.

.386
.model flat, c

;; https://programminghaven.home.blog/2020/02/16/setup-an-assembly-project-on-visual-studio-2019/
;; custom build step taken from https://github.com/microsoft/VCSamples had code-rot
;; https://github.com/microsoft/VCSamples/tree/master/VC2010Samples/Compiler/MASM

; Custom Build Step, including a listing file placed in intermediate directory
; but without Source Browser information
; debug:
; ml -c -Zi "-Fl$(IntDir)\$(InputName).lst" "-Fo$(IntDir)\$(InputName).obj" "$(InputPath)"
; release:
; ml -c "-Fl$(IntDir)\$(InputName).lst" "-Fo$(IntDir)\$(InputName).obj" "$(InputPath)"
; outputs:
; $(IntDir)\$(InputName).obj

; Custom Build Step, including a listing file placed in intermediate directory
; and Source Browser information also placed in intermediate directory
; debug:
; ml -c -Zi "-Fl$(IntDir)\$(InputName).lst" "-FR$(IntDir)\$(InputName).sbr" "-Fo$(IntDir)\$(InputName).obj" "$(InputPath)"
; release:
; ml -c "-Fl$(IntDir)\$(InputName).lst" "-FR$(IntDir)\$(InputName).sbr" "-Fo$(IntDir)\$(InputName).obj" "$(InputPath)"
; outputs:
; $(IntDir)\$(InputName).obj
; $(IntDir)\$(InputName).sbr

.code

; Euclid's algorithm finds the greatest common divisor by repeatedly
; subtracting the smaller number from the larger number until zero
; is reached. The number remaining is the greatest common divisor.

euclid PROC x:SDWORD, y:SDWORD
  mov ecx, x
  mov eax, y
;; https://docs.microsoft.com/en-us/cpp/assembler/masm/at-at?view=msvc-170
;; Defines a code label recognizable only between label1 and label2,
;; where label1 is either start of code or the previous @@: label, and
;; label2 is either end of code or the next @@: label. See @B and @F.
@@:
  cmp ecx, eax
  jge noswap
  xchg eax, ecx
noswap:
  sub ecx, eax
;; https://docs.microsoft.com/en-us/cpp/assembler/masm/at-b?view=msvc-170
;; @B - The location of the previous @@: label.
jnz @B
;; https://docs.microsoft.com/en-us/cpp/assembler/masm/at-f?view=msvc-170
;; @F - The location of the next @@: label.

; return value already in eax
  RET
euclid ENDP

end
