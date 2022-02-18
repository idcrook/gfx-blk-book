@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasmr -wx -d1 -ms -fo=L32P1.obj L32P1
WDIS L32P1.OBJ > L32P1.DIS
