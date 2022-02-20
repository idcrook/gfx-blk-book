@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L30P1.obj L30P1
WDIS L30P1.OBJ > L30P1.DIS
wcl -d1 -l=dos -fe=L30P1.exe L30P1.obj