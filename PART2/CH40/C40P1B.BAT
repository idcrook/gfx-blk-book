@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -bt=dos /dCONVEX_CODE_LINKED -fo=0P1B.obj -c L40P1.c
wcl -q -d1 -bt=dos  -fo=L40P2.obj -c L40P2.c
wcl -q -d1 -bt=dos  -fo=L40P4.obj -c L40P4.c

@REM @REM reuse from chapter 38
wcl -q -d1 -bt=dos /dUSE_ASM_SCANEDGE /dUSE_ASM_HLINELIST -fo=8P1B.obj -c ..\CH39\L38P1.c
wasm -wx -d1 -ms -fo=9P3B.obj ..\CH39\L39P3
wasm -wx -d1 -ms -fo=9P4B.obj ..\CH39\L39P4


wcl -d1 -ms -l=dos -fe=L40P1B.exe L40P4.obj 0P1B.obj L40P2.obj 8P1B.obj 9P3B.obj 9P4B.obj
