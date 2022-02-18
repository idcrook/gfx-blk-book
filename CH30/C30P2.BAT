@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L30P2.obj L30P2
WDIS L30P2.OBJ > L30P2.DIS
wcl -d1 -l=dos -fe=L30P2.exe L30P2.obj