@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -bt=dos -fo=L44P1.obj -c L44P1.c
wasm -wx -d1 -ms   -fo=L44P2.obj    L44P2

wcl -d1 -ms -l=dos -fe=L44P1.exe L44P1.obj L44P2.obj
