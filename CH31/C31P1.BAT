@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L31P1.obj L31P1
WDIS L31P1.OBJ > L31P1.DIS
wcl -d1 -l=dos -fe=L31P1.exe L31P1.obj