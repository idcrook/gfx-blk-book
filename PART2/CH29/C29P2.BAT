@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L29P2.obj L29P2
WDIS L29P2.OBJ > L29P2.DIS
wcl -d1 -l=dos -fe=L29P2.exe L29P2.obj