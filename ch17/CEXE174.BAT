@echo %WATCOM%
del *.err *.obj

wcl -3 -q -fpi87 -fp3 -os -d0 -mh -bt=dos -fo=L17-4M.obj -c L17-4M.cpp
wcl -3 -q -fpi87 -fp3 -os -d2 -mh -bt=dos -fo=L17-2.obj -c L17-2.cpp
@REM wdis L17-2.obj > L17-2.dis
wcl -3 -fpi87 -fp3 -os -d0 -mh -l=dos -fe=L17-4M.exe L17-4M.obj L17-2.obj