@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L26P2.obj L26P2
WDIS L26P2.OBJ > L26P2.DIS
wcl -d1 -l=dos -fe=L26P2.exe L26P2.obj