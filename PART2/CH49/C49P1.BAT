@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -ms -l=dos -fe=L49P1.exe L49P5 L49P1 L49P2 L49P3 L49P6 L47P1 ..\CH48\L48P2 ..\CH48\L48P3 ..\CH48\L48P4 ..\CH47\L47P6
