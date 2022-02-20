@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -ms -fo=L34P1.obj L34P1
WDIS L34P1.OBJ > L34P1.DIS
wcl -d1 -l=dos -fe=L34P1.exe L34P1.obj