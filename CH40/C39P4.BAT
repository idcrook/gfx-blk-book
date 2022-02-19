@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -bt=dos  -fo=L40P1.obj -c L40P1.c
wcl -q -d1 -bt=dos  -fo=L40P2.obj -c L40P2.c
wcl -q -d1 -bt=dos  -fo=L40P4.obj -c L40P4.c
wasm -wx -d1 -ms -fo=L40P5.obj L40P5

@REM @REM reuse from chapter 38
@REM wcl -q -d1 -bt=dos /dUSE_ASM_SCANEDGE /dUSE_ASM_HLINELIST -fo=L38P1B.obj -c L38P1.c
@REM wcl -q -d1 -bt=dos  -fo=L38P3.obj -c L38P3.c

wcl -d1 -ms -l=dos -fe=L40P1.exe  L40P4.obj L40P1.obj L40P2.obj
