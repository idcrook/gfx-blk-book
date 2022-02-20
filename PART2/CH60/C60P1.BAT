@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM Chapter 60 source  
@REM wcl -q -3 -d1 -bt=dos -fo=L60P1.obj    -c L60P1.C
wcl -q -3 -d1 -bt=dos -fo=L60P1.obj -c L60P1.CPP


