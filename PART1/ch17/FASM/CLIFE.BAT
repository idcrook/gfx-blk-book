@echo %WATCOM%
del *.err 
del *.obj
del *.dis
del *.lst
@REM del *.smp

@REM -3 or higher yields linker Warning! W1080: file LIFE.obj is a 32-bit object file
@REM -2 does not have a linker warning 
wasm -4p -fpi87 -d1 -mt life.asm
wdis -a -p -l LIFE.obj
wlink DISABLE 1080 file LIFE.obj format dos com name LIFE.com

wcl -d0 -mt -bt=dos -fo=excom.obj -c excom.asm
wlink file EXCOM.obj format dos com name EXCOM.com

@REM watcom 1.9 has bug that does not allow this. 
@REM Warning! W1098: Offset option must be a multiple of 4096
@REM Fixed in watcom 2
@REM https://github.com/open-watcom/open-watcom-v2/commit/0da3c02c8b0141b9b39fb5565485397a8cbbb0b6
@REM can be ignored for .COM: Warning! W1014: stack segment not found 
@REM Because relocation to 0x100 is done by wlink raw format you must not 
@REM use ORG 100h directive in ASM source file.
@REM wlink file excom.obj format raw bin op offset=0x100 name test.com