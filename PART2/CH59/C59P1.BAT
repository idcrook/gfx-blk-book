@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM Chapter 59 source  
@REM wcl -q -3 -d1 -bt=dos -fo=L59P1.obj -c L59P1.c
@REM wcl -q -3 -d1 -bt=dos -fo=L59P2.obj -c L59P2.c
@REM wcl -q -3 -d1 -bt=dos -fo=L59P4.obj -c L59P4.c

@REM wcl -q -3 -d1 -bt=dos -fo=L59P1.exe -c L59P5.c

@REM wcl -q -3 -d1 -bt=dos -fo=TESTTIME.exe -c TESTTIME.c

@echo time() and printf() functions seem to hang