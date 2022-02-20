@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM wcl -q -d1 -bt=dos -fo=L46P1.obj -c L46P1.c
@REM wasm -wx -d1 -ms   -fo=L46P2.obj    L46P2

wcl -d1 -ms -l=dos -fe=L46P1.exe L46P1 L46P2
