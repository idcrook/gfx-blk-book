@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM wcl -q -d1 -bt=dos -fo=L48P1.obj -c L48P1.c
@REM wasm -wx -d1 -ms   -fo=L48P2.obj    L48P2

wcl -d1 -ms -l=dos -fe=L48P1.exe L48P1 L47P1 L48P2
wasm -wx -d1 -ms   -fo=L48P3.obj    L48P3
wasm -wx -d1 -ms   -fo=L48P4.obj    L48P4
