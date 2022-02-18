@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -ms -fo=L32P1.obj L32P1
@REM WDIS L32P1.OBJ > L32P1.DIS
@REM wcl -d1 -l=dos -fe=L32P1.exe L32P1.obj