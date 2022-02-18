@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L27P2.obj L27P2
WDIS L27P2.OBJ > L27P2.DIS
wcl -d1 -l=dos -fe=L27P2.exe L27P2.obj