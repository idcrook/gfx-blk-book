@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L27P3.obj L27P3
WDIS L27P3.OBJ > L27P3.DIS
wcl -d1 -l=dos -fe=L27P3.exe L27P3.obj