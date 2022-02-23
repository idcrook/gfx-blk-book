@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -d1 -ms -l=dos -fe=L45P1.exe L45P1
