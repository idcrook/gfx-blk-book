@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L26P1.obj L26P1
WDIS L26P1.OBJ > L26P1.DIS
wcl -d1 -l=dos -fe=L26P1.exe L26P1.obj