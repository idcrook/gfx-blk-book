@echo %WATCOM%
del *.err 
del *.obj

wcl -3 -q -fpi87 -fp3 -os -d2 -mh -bt=dos -fo=L17-5.obj -c L17-5.cpp
@REM wcl -3 -q -fpi87 -fp3 -os -d2 -mh -bt=dos -fo=L17-2.obj -c L17-2.cpp
wcl -3 -q -fpi87 -fp3 -ox -d2 -mh -bt=dos -fo=L17-2.obj -c L17-2.cpp
wdis L17-2.obj > L17-2.dis
wcl -3 -fpi87 -fp3 -os -d2 -mh -l=dos -fe=L175.exe L17-5.obj L17-2.obj