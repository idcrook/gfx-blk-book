@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -bt=dos /dUSE_ASM_HLINELIST -fo=L38P1.obj -c L38P1.c

wcl -q -d1 -ms -l=dos -fe=L50P1.exe L50P5 L50P1 L50P2 L50P3 L38P1.obj ..\CH47\L47P1 ..\CH47\L47P6 ..\CH49\L49P6

