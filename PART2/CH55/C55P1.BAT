@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM Chapter 55 source  
wcl -q -3 -d1 -bt=dos -fo=L55P2.obj    -c L55P2.C
@REM wcl -q -3 -d1 -bt=dos -fo=L55P3.obj -c L55P3.C

