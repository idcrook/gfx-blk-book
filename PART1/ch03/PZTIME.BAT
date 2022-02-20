
echo off
rem
rem *** Listing 3.4 ***
rem
rem ***************************************************************
rem * Batch file PZTIME.BAT, which builds and runs the precision  *
rem * Zen timer program PZTEST.EXE to time the code named as the  *
rem * command-line parameter. Listing 3.1 must be named           *
rem * PZTIMER.ASM, and Listing 3.2 must be named PZTEST.ASM. To   *
rem * time the code in LST3-3, you'd type the DOS command:        *
rem *                                                             *
rem * pztime lst3-3                                               *
rem *                                                             *
rem * Note that MASM and LINK must be in the current directory or *
rem * on the current path in order for this batch file to work.   *
rem *                                                             *
rem * This batch file can be speeded up by assembling PZTIMER.ASM *
rem * once, then removing the lines:                              *
rem *                                                             *
rem * masm pztimer;                                               *
rem * if errorlevel 1 goto errorend                               *
rem *                                                             *
rem * from this file.                                             *
rem *                                                             *
rem * By Michael Abrash                                           *
rem ***************************************************************
@REM SET PATH=C:\DEVEL\OW\BINW;%PATH%;
@REM SET INCLUDE=C:\DEVEL\OW\H;
@REM SET WATCOM=C:\DEVEL\OW
@REM SET EDPATH=C:\DEVEL\OW\EDDAT
@REM SET WIPFC=C:\DEVEL\OW\WIPFC
echo %WATCOM%
del *.ERR
rem
rem Make sure a file to test was specified.
rem
if not x%1==x goto ckexist
echo ***************************************************************
echo * Please specify a file to test.                              *
echo ***************************************************************
goto end
rem
rem Make sure the file exists.
rem
:ckexist
if exist %1 goto docopy
echo ***************************************************************
echo * The specified file, "%1," doesn't exist.                    *
echo ***************************************************************
goto end
rem
rem copy the file to measure to TESTCODE.
rem
:docopy
@echo on
copy %1 testcode
wasm -zq pztest
if errorlevel 1 goto errorend
wasm -zq pztimer
if errorlevel 1 goto errorend
wlink name pztest.exe format dos file pztest.obj file pztimer.obj
if errorlevel 1 goto errorend
pztest.exe
goto end
:errorend
echo ***************************************************************
echo * An error occurred while building the precision Zen timer.   *
echo ***************************************************************
:end