@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp



wcl -q -d1 -bt=dos  -fo=L42P1.obj -c L42P1.c
@REM main()
wcl -q -d1 -bt=dos  -fo=L42P2.obj -c L42P2.c
@REM wcl -q -d1 -bt=dos  -fo=L42P3.obj -c L42P3.c
wcl -q -d1 -bt=dos  -fo=L42P4.obj -c L42P4.c
wcl -q -d1 -bt=dos  -fo=L42P5.obj -c L42P5.c
@REM wasm -wx -d1 -ms -fo=L42P6.obj L42P6

wcl -d1 -ms -l=dos -fe=L42P2.exe L42P2.obj L42P1.obj   L42P4.obj L42P5.obj 

@echo.
@echo *** Requires Tseng Labs ET4000-based SuperVGAs emulation in dosbox-x
@echo  machine = svga_et4000 
