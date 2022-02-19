@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp



wcl -q -d1 -bt=dos  -fo=L39P1.obj -c L39P1.c
wcl -q -d1 -bt=dos  -fo=L39P2.obj -c L39P2.c

@REM reuse from chapter 38
wcl -q -d1 -bt=dos  -fo=L38P1.obj -c L38P1.c
wcl -q -d1 -bt=dos  -fo=L38P3.obj -c L38P3.c

@REM wasm -wx -d1 -ms -fo=L39P3.obj L39P3
@REM wcl -q -d1 -bt=dos /dUSE_ASM_EVGALINE=1 -fo=L36P2A.obj -c L36P2.c
@REM wcl -q -d1 -bt=dos  -fo=L39P3.obj -c L38P3.c

@REM wcl  -d1 -ms -l=dos -bcl=dos -lr -fe=L39P1.exe L39P1 L39P2 L38P3
wcl -q -d1 -ms -l=dos -fe=L39P1.exe L39P1 L39P2 L38P1 L38P3


@REM wcl -d1 -l=dos -fe=L37P1.exe L37P1.obj L36P2A.obj