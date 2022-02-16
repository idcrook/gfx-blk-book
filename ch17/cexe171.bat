@echo %WATCOM%
del *.err
@REM wcl -3 -fpi87 -fp3 -os -d0 -mt -bt=dos -fo=L17-1.obj -c L17-1.cpp
@REM wcl -3 -fpi87 -fp3 -os -d0 -mt -bt=dos -fo=L17-2.obj -c L17-2.cpp
@REM wcl -3 -fpi87 -fp3 -os -d0 -mt -l=com -fe=L17-1.com L17-1.obj L17-2.obj
wcl -3 -q -fpi87 -fp3 -os -d0 -mh -bt=dos -fo=L17-1.obj -c L17-1.cpp
wcl -3 -q -fpi87 -fp3 -os -d2 -mh -bt=dos -fo=L17-2.obj -c L17-2.cpp
@REM wdis L17-2.obj > L17-2.dis
wcl -3 -fpi87 -fp3 -os -d0 -mh -l=dos -fe=L17-1.exe L17-1.obj L17-2.obj