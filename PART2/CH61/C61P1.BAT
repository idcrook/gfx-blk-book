@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM Chapter 61 source  
wcl -q -3 -d1 -bt=dos -fo=L61P1.obj -c L61_1.C


