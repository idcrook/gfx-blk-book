@echo %WATCOM%
del *.err
wcl -3 -q -fpi87 -fp3 -os -d0 -mh -bt=dos -fo=pixel.obj -c pixel.c
wdis pixel.obj > pixel.dis
wcl -3 -q -fpi87 -fp3 -os -d0 -mh -l=dos -fe=testpx.exe pixel.obj