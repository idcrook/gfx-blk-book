@echo %WATCOM%
del *.err 
@REM del *.obj
@REM del *.dis
del *.smp


wcl386 -q -6s -zp4 -oneatx -d1 -bt=dos -fo=L175P.obj -c L175PRO.cpp
@REM wdis L175P.obj > L175P.dis
wcl386 -q -6s -zp4 -oneatx -d1 -bt=dos -fo=L172P.obj -c L172PRO.cpp
wdis L172P.obj > L172P.dis
wcl386    -6s -zp4 -oneatx -d1 -l=dos4g -fe=L175P.exe L175P.obj L172P.obj

wcl -q -6 -zp4 -oneatx -d1 -bt=dos -fo=L175R.obj -c L175PRO.cpp
@REM wdis L175R.obj > L175R.dis
wcl -q -6 -zp4 -oneatx -d1 -bt=dos -fo=L172R.obj -c L172PRO.cpp
wdis L172R.obj > L172R.dis
wcl    -6 -zp4 -oneatx -d1 -l=dos -fe=L175R.exe L175R.obj L172R.obj