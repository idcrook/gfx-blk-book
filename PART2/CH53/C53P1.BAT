@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -bt=dos /dUSE_ASM_HLINELIST -fo=L38P1.obj -c L38P1.c
wcl -q -d1 -bt=dos -fo=L50P1.obj -c ..\CH50\L50P1.asm
wcl -q -d1 -bt=dos -fo=L47P1.obj -c ..\CH47\L47P1.asm
wcl -q -d1 -bt=dos -fo=L47P6.obj -c ..\CH47\L47P6.asm
wcl -q -d1 -bt=dos -fo=L49P6.obj -c ..\CH49\L49P6.asm
wcl -q -d1 -bt=dos -fo=L39P4.obj -c ..\CH39\L39P4


wcl -q -d1 -ms -l=dos -fe=L52P1.exe L52P*.c L52P*.asm L38P1.obj L47P1.obj L47P6.obj L49P6.obj L39P4.obj L50P1.obj

