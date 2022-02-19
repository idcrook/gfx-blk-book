@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -bt=dos  -fo=L41P1.obj -c L41P1.c
wcl -q -d1 -bt=dos  -fo=L41P2.obj -c L41P2.c
wasm -wx -d1 -ms -fo=L41P3.obj L41P3
wcl -q -d1 -bt=dos  -fo=L41P4.obj -c L41P4.c
wasm -wx -d1 -ms -fo=L39P4.obj L39P4
wasm -wx -d1 -ms -fo=L40P5.obj L40P5

@REM main()
wcl -q -d1 -bt=dos  -fo=L40P4.obj -c L40P4.c

wcl -d1 -ms -l=dos -fe=L41P1.exe L40P4.obj L41P1.obj L41P2.obj L41P3.obj L41P4.obj L39P4.obj L40P5.obj
