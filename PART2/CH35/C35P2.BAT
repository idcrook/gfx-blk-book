@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM wcl386 -q -6s -zp4 -oneatx -d1 -bt=dos  -fo=L35P1.obj -c L35P1.c
wcl -q -d1 -bt=dos  -fo=L35P1.obj -c L35P1.c
wcl -q -d1 -bt=dos  -fo=L35P2.obj -c L35P2.c
wcl -d1 -ms -l=dos -fe=L35P2.exe L35P1.obj L35P2.obj