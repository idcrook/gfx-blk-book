@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L28P1.obj L28P1
WDIS L28P1.OBJ > L28P1.DIS
wcl -d1 -l=dos -fe=L28P1.exe L28P1.obj