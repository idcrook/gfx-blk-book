@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L28P3.obj L28P3
WDIS L28P3.OBJ > L28P3.DIS
wcl -d1 -l=dos -fe=L28P3.exe L28P3.obj