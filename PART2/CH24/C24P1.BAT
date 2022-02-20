@echo %WATCOM%
del *.err 
del *.obj
del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L24P1.obj L24P1
WDIS L24P1.OBJ > L24P1.DIS
wcl -d1 -l=dos -fe=L24P1.exe L24P1.obj 