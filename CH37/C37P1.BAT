@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM wcl386 -q -6s -zp4 -oneatx -d1 -bt=dos  -fo=L35P1.obj -c L35P1.c

wasm -wx -d1 -ms -fo=L37P1.obj L37P1
wcl -q -d1 -bt=dos /dUSE_ASM_EVGALINE=1 -fo=L36P2A.obj -c L36P2.c
wcl -d1 -l=dos -fe=L37P1.exe L37P1.obj L36P2A.obj