@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -bt=dos  -fo=L39P1.obj -c L39P1.c
wcl -q -d1 -bt=dos  -fo=L39P2.obj -c L39P2.c

@REM reuse from chapter 38
wcl -q -d1 -bt=dos /dUSE_CH39_SCANEDGE -fo=L38P1A.obj -c L38P1.c
wcl -q -d1 -bt=dos  -fo=L38P3.obj -c L38P3.c

wcl -d1 -ms -l=dos -fe=L39P2.exe L38P3.obj L38P1A.obj L39P1.obj L39P2.obj
