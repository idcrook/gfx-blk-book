@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L28P2.obj L28P2
WDIS L28P2.OBJ > L28P2.DIS
wcl -d1 -l=dos -fe=L28P2.exe L28P2.obj