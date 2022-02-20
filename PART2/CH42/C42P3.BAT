@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM wcl -q -d1 -bt=dos  -fo=L42P1.obj -c L42P1.c
wcl -q -d1 -bt=dos /dUSE_ASM_DRAWWULINE=1 -fo=L42P2A.obj -c L42P2.c
wcl -q -d1 -bt=dos  -fo=L42P3.obj -c L42P3.c
wcl -q -d1 -bt=dos  -fo=L42P4.obj -c L42P4.c
wasm -wx -d1 -ms -fo=L42P6.obj L42P6

wcl -d1 -ms -l=dos -fe=L42P3.exe L42P2A.obj L42P6.obj L42P3.obj L42P4.obj 
