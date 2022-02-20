@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wasm -wx -d1 -ms -fo=L43P1.obj L43P1

wcl -d1 -ms -l=dos -fe=L43P1.exe L43P1.obj