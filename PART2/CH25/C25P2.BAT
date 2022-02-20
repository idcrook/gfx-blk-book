@echo %WATCOM%
del *.err 
del *.obj
@REM L  del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L25P2.obj L25P2
WDIS L25P2.OBJ > L25P2.DIS
wcl -d1 -l=dos -fe=L25P2.exe L25P2.obj