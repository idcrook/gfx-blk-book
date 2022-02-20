@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM wcl -q -d1 -bt=dos -fo=L45P1.obj -c L45P1.c
@REM wasm -wx -d1 -ms   -fo=L45P2.obj    L45P2

wcl -d1 -ms -l=dos -fe=L45P3.exe  L45P3 L45P4
