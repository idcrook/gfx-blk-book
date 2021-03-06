; 16-bit COM file example
; nasm hellocom.asm -fbin -o hellocom.com
; to run in MS DOS / DosBox: hellocom.com
; https://github.com/soothscier/assembly-nasm/blob/master/hello.asm

.model tiny

CSEG		SEGMENT	PARA  USE16 
	assume CS:_TEXT, DS:_TEXT, ES:_TEXT
    
org 100h 

start:
  ; program code
  ;mov  dx,  msg  ;  '$'-terminated string ; EXCOM.ASM(14): Error! E039: Operands must be the same size
  ;mov  dx, offset DGROUP:msg;  '$'-terminated string
  mov  dx, offset msg;  '$'-terminated string
  mov  ah, 09h; write string to standard output from DS:DX
  int  0x21   ; call dos services
 
  mov ah,4Ch
  int 21h

  int 20h
 
; section .data
;  .data
  ; program data
 
  msg  db 'Hello world'
  crlf db 0x0d, 0x0a
  endstr db '$'

; section .bss
;  .bss
  ; uninitialized data

  CSEG ENDS 


  end start
