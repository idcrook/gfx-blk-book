@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -bt=dos /dUSE_ASM_HLINELIST -fo=L38P1.obj -c L38P1.c
wcl -q -d1 -bt=dos -fo=L47P1.obj -c ..\CH47\L47P1.asm
wcl -q -d1 -bt=dos -fo=L47P6.obj -c ..\CH47\L47P6.asm
wcl -q -d1 -bt=dos -fo=L49P6.obj -c ..\CH49\L49P6.asm
wcl -q -d1 -bt=dos -fo=L50P1.obj -c ..\CH50\L50P1
wcl -q -d1 -bt=dos -fo=L50P2.obj -c ..\CH50\L50P2

wcl  -d1 -ms -l=dos -fe=L51P1.exe L51P1 L51P2 L51P3 L51P4 L38P1.obj L47P1.obj L47P6.obj L49P6.obj L50P1.obj L50P2.obj 
@REM ..\CH47\L47P1 ..\CH47\L47P6 ..\CH49\L49P6 ..\CH50\L50P1 ..\CH50\L50P2

