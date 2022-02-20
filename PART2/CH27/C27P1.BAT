@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L27P1.obj L27P1
WDIS L27P1.OBJ > L27P1.DIS
wcl -d1 -l=dos -fe=L27P1.exe L27P1.obj