@echo %WATCOM%
del *.err 
del *.obj
del *.dis
del *.smp

wasm -wx -d1 -mh -fo=L23P1.obj L23P1
WDIS L23P1.OBJ > L23P1.DIS
@REM wcl386 -6 -zp4 -oneatx -d1 -l=dos4g -fe=L23P1.exe L23P1.obj 
wcl -d1 -l=dos -fe=L23P1.exe L23P1.obj 