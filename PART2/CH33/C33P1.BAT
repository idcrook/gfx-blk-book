@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -ms -fo=L33P1.obj L33P1
WDIS L33P1.OBJ > L33P1.DIS
wcl -d1 -l=dos -fe=L33P1.exe L33P1.obj