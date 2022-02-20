@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L29P3.obj L29P3
WDIS L29P3.OBJ > L29P3.DIS
wcl -d1 -l=dos -fe=L29P3.exe L29P3.obj