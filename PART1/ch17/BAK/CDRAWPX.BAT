@echo %WATCOM%
del *.err
wcl -3 -q -fpi87 -fp3 -os -d0 -mh -bt=dos -fo=t_dpx.obj -c t_dpx.cpp
wcl -3 -q -fpi87 -fp3 -os -d2 -mh -bt=dos -fo=drawpx.obj -c drawpx.cpp
wdis drawpx.obj > drawpx.dis
wcl -3 -q -fpi87 -fp3 -os -d0 -mh -l=dos -fe=testdpx.exe t_dpx.obj drawpx.obj