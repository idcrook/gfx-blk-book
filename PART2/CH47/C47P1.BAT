@echo %WATCOM%
del *.err 
del *.obj
@REM del *.dis
del *.smp

wcl -q -d1 -ms -l=dos -fe=L47P1_S.exe L47P7 L47P1 L47P2 L47P3 L47P4
wcl -q -d1 -ms -l=dos -fe=L47P1_M.exe L47P7 L47P1 L47P2 L47P3 L47P5
wcl -d1 -ms -l=dos -fe=L47P1_F.exe L47P7 L47P1 L47P2 L47P3 L47P6
