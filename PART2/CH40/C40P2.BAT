@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -bt=dos /dUSE_ASM_HLINELIST -fo=L40P1.obj -c L40P1.c
@REM HLINELIST # wcl -q -d1 -bt=dos  -fo=L40P2.obj -c L40P2.c
wasm -wx -d1 -ms -fo=L40P5.obj L40P5
wcl -q -d1 -bt=dos  -fo=L40P2.obj -c L40P2.c
wcl -q -d1 -bt=dos  -fo=L40P4.obj -c L40P4.c

wcl -d1 -ms -l=dos -fe=L40P2.exe  L40P4.obj L40P1.obj L40P5.obj
