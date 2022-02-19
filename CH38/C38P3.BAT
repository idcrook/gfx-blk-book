@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
@REM del *.smp

wcl -q -d1 -bt=dos  -fo=L38P1.obj -c L38P1.c
wcl -q -d1 -bt=dos  -fo=L38P2.obj -c L38P2.c
wcl -q -d1 -bt=dos  -fo=L38P3.obj -c L38P3.c

wcl -q -d1 -ms -l=dos -fe=L38P3.exe L38P1 L38P2 L38P3