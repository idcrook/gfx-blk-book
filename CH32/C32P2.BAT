@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM wasm -wx -d1 -ms -fo=L32P1.obj L32P1
@REM @REM WDIS L32P1.OBJ > L32P1.DIS
wcl -d1 -l=dos -fe=L32P2.exe L32P2 
@REM L32P1
@REM L32P1.obj