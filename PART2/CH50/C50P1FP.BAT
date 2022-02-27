@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp



wcl -q -d1 -ms -bt=dos -fo=L50P1.obj -c L50P1.asm
wcl -q /oneatx /oh /fpi87 /fp3 /5 -d1 -ms -bt=dos /dUSE_ASM_HLINELIST -fo=L38P1.obj -c L38P1.c
wcl -q -d1 -ms -bt=dos -fo=L47P1.obj -c ..\CH47\L47P1.asm
wcl -q -d1 -ms -bt=dos -fo=L47P6.obj -c ..\CH47\L47P6.asm 
wcl -q -d1 -ms -bt=dos -fo=L49P6.obj -c ..\CH49\L49P6.asm

wcl /oneatx /oh /fp3 /5 -d1 -ms -l=dos -fe=L50P1FP.exe L50P5 L50P1.obj L50P2 L50P3 L38P1.obj L47P1.obj L47P6.obj L49P6.obj
WDIS L50P2.obj > L50P2.dis
