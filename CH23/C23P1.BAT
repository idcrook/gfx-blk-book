@echo %WATCOM%
del *.err 
del *.obj
del *.dis
del *.smp

wasm -zq -6p -d1 -fo=L23P1.obj L23P1
wcl386 -6s -zp4 -oneatx -d1 -l=dos4g -fe=L23P1.exe L23P1.obj 