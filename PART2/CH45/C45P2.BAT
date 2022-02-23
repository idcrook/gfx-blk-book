@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -d1 -ms -l=dos -fe=L45P2.exe L45P2 L45P3
