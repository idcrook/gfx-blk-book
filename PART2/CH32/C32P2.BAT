@echo %WATCOM%
del *.err 
@rem del *.obj
@REM del *.dis
del *.smp

wasmr -wx -d1 -ms -fo=L32P1.obj L32P1
@REM WDIS L32P1.OBJ > L32P1.DIS
wcl -d1 -ms -l=dos -fe=L32P2.exe L32P2 L32P1.obj
@REM WDIS L32P2.OBJ > L32P2.DIS
