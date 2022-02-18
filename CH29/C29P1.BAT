@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L29P1.obj L29P1
WDIS L29P1.OBJ > L29P1.DIS
wcl -d1 -l=dos -fe=L29P1.exe L29P1.obj