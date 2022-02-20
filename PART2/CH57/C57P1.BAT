@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM Chapter 57 source  
@REM wcl -q -3 -d1 -bt=dos -fo=L57P1.obj    -c L57P1.C
@REM L56P2.C includes L57P1.C
wcl -q -3 -d1 -bt=dos -fo=L56P2U.obj -c L56P2.C
wcl -q -3 -d1 -bt=dos -fo=L57P2.obj -c L57P2.asm


