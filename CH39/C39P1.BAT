@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -bt=dos  -fo=L39P1.obj -c L39P1.c
@REM reuse from chapter 38
wcl -q -d1 -bt=dos  -fo=L38P1.obj -c L38P1.c
wcl -q -d1 -bt=dos  -fo=L38P3.obj -c L38P3.c

wcl -d1 -mc -l=dos -fe=L39P1.exe L38P3.obj L39P1.obj L38P1.obj
