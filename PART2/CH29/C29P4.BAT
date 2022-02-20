@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L29P4.obj L29P4
WDIS L29P4.OBJ > L29P4.DIS
wcl -d1 -l=dos -fe=L29P4.exe L29P4.obj