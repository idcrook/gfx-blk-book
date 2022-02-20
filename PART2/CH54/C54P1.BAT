@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

@REM Chapter 54 source
wcl -q -3 -d1 -bt=dos -fo=FIXED.obj -c L54P1.ASM
wcl -q -3 -d1 -bt=dos -fo=DRAWPOBJ.obj -c L54P2.C

