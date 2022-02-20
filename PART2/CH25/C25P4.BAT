@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L25P4.obj L25P4
WDIS L25P4.OBJ > L25P4.DIS
wcl -d1 -l=dos -fe=L25P4.exe L25P4.obj