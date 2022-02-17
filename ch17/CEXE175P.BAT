@echo %WATCOM%
del *.err 
del *.obj
del *.dis
del *.smp

@REM wcl386 -3r -q  -os -d2 -bt=dos -fo=L175P.obj -c L175PRO.cpp
@REM wcl386 -3r -q  -os -d2 -bt=dos -fo=L172P.obj -c L172PRO.cpp

wcl386 -q -6s -zp4 -oneatx -d1 -bt=dos -fo=L175P.obj -c L175PRO.cpp
wdis L175P.obj > L175P.dis
wcl386 -q -6s -zp4 -oneatx -d1 -bt=dos -fo=L172P.obj -c L172PRO.cpp
wdis L172P.obj > L172P.dis
wcl386    -6s -zp4 -oneatx -d1 -l=dos4g -fe=L175PRO.exe L175P.obj L172P.obj