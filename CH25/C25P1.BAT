@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L25P1.obj L25P1
WDIS L25P1.OBJ > L25P1.DIS
wcl -d1 -l=dos -fe=L25P1.exe L25P1.obj 