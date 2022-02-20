@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM wcl -q -d1 -bt=dos -fo=L39P1.obj -c L39P1.c
wcl -q -d1 -bt=dos  -fo=L39P2.obj -c L39P2.c
wasm -wx -d1 -ms -fo=L39P3.obj L39P3

@REM reuse from chapter 38
wcl -q -d1 -bt=dos /dUSE_CH39_SCANEDGE /dUSE_ASM_HLINELIST -fo=L38P1B.obj -c L38P1.c
wcl -q -d1 -bt=dos  -fo=L38P3.obj -c L38P3.c

wcl -d1 -mc -l=dos -fe=L39P3.exe L38P3.obj L38P1B.obj   L39P2.obj L39P3.obj 
