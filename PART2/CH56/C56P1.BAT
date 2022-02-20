@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM Chapter 56 source  
wcl -q -3 -d1 -bt=dos -fo=L56P2.obj -c L56P2.C

