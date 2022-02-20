@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L25P3.obj L25P3
WDIS L25P3.OBJ > L25P3.DIS
wcl -d1 -l=dos -fe=L25P3.exe L25P3.obj