@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L31P2.obj L31P2
WDIS L31P2.OBJ > L31P2.DIS
wcl -d1 -l=dos -fe=L31P2.exe L31P2.obj