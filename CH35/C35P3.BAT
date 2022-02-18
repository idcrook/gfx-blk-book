@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM wcl386 -q -6s -zp4 -oneatx -d1 -bt=dos  -fo=L35P1.obj -c L35P1.c

wasm -wx -d1 -ms -fo=L35P3.obj L35P3
WDIS L35P3.OBJ > L35P3.DIS
wcl -q -d1 -bt=dos /dUSE_ASM_EVGALINE=1 -fo=L35P2A.obj -c L35P2.c
wcl -d1 -l=dos -fe=L35P3.exe L35P3.obj L35P2A.obj