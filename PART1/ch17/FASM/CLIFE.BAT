@echo %WATCOM%
del *.err 
del *.obj
del *.dis
del *.lst
del *.smp

@REM wcl -3 -fpi87 -fp3 -os -d0 -mt -bt=dos -l=com -fe=hello.com hello.cc

@REM wcl -3 -fpi87 -fp3 -os -d0 -mt -bt=dos -fo=hello.obj -c hello.cc
@REM wcl -3 -fpi87 -fp3 -os -d0 -mt -l=com -fe=hello.com hello.obj

@REM wcl -2 -d1 -mt -bt=dos -l=com -fe=life.com LIFE.ASM

@REM wcl -3 -fpi87 -fp3 -d1 -mt -bt=dos -fo=life.obj -c life.asm
@REM wasm -3 -mt life.asm
@REM wcl   -3 -fpi87 -fp3 -os -d0 -mt -lr -l=com -fe=life.com life.obj
@REM wdis -l -a life.obj

@REM wcl -d1 -mt -bt=dos -fo=LIFE.obj -c LIFE.ASM
@REM wlink file LIFE.obj format dos com name LIFE.com

wasm -2 -mt life.asm
wlink file LIFE.obj format dos com name LIFE.com

@REM wcl -d0 -mt -bt=dos -fo=excom.obj -c excom.asm
@REM wlink file EXCOM.obj format dos com name EXCOM.com