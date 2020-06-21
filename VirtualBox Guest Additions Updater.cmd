@echo off

REM ----------------------------------------------------------------------------
REM -                                                                          -
REM - VirtualBox Guest Additions Updater                                       -
REM -                                                                          -
REM - Created by Fonic (https://github.com/fonic)                              -
REM - Date: 03/18/17 - 06/21/20                                                -
REM -                                                                          -
REM ----------------------------------------------------------------------------


REM ------------------------------------
REM -                                  -
REM - Globals                          -
REM -                                  -
REM ------------------------------------
:globals

REM Enter local environment scope, enable delayed expansion
setlocal enabledelayedexpansion

REM Define globals
set SCRIPT_TITLE=VirtualBox Guest Additions Updater
set VBOX_SETUP_FILE=VBoxWindowsAdditions.exe
set VBOX_SETUP_OPTS=
set VBOX_INSTALL_DST=%PROGRAMFILES%\VirtualBox Guest Additions
set VBOX_ENTRY_SRC=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox Guest Additions
set VBOX_ENTRY_DST=%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Oracle VirtualBox

REM Determine if script is running with administrator privileges
(net session >NUL 2>&1) && (set IS_ADMINISTRATOR=true) || (set IS_ADMINISTRATOR=false)

REM Determine if script was executed from an interactive shell
(echo %CMDCMDLINE% | find /i "%~0" >NUL 2>&1) && (set IS_INTERACTIVE=false) || (set IS_INTERACTIVE=true)


REM ------------------------------------
REM -                                  -
REM - Main                             -
REM -                                  -
REM ------------------------------------
:main

REM Set window title, clear screen, print title
if "%IS_INTERACTIVE%" == "false" (
	title %SCRIPT_TITLE%
	cls
)
echo.
echo ---=== %SCRIPT_TITLE% ===---
echo.

REM Abort if not running with administrator privileges
if "%IS_ADMINISTRATOR%" == "false" (
	echo Error: this script needs to be run as administrator
	goto exit
)

REM Search all available CD-ROM drives for setup
REM
REM NOTE:
REM Relies on 'setlocal enabledelayedexpansion'
REM
REM Sources:
REM https://social.technet.microsoft.com/Forums/scriptcenter/en-US/12ec0bda-27b2-4555-adb7-d25ad68d9520/batch-file-check-if-cd-is-in-drive?forum=ITCG
REM http://support.moonpoint.com/os/windows/commands/wmic/logicaldisk.php
REM https://superuser.com/a/1192171
REM https://superuser.com/a/1082547
echo Searching CD-ROM drives for setup...
set setup=
for /f "skip=1 tokens=1" %%d in ('wmic logicaldisk where "DriveType=5" get deviceid 2^>NUL ^| findstr /r /v "^$"') do (
	if "!setup!" == "" (
		dir "%%d" >NUL 2>&1 && if exist "%%d\%VBOX_SETUP_FILE%" set setup=%%d\%VBOX_SETUP_FILE%
	)
)

REM Run setup (NOTE: option '/D=' of setup will only be recognized without
REM quotes; however, paths containing spaces will still work just fine)
if not "%setup%" == "" (
	echo Setup located: %setup%
	echo Running setup, please wait...
	"%setup%" %VBOX_SETUP_OPTS% /S /D=%VBOX_INSTALL_DST%
	echo Moving start menu entry...
	if exist "%VBOX_ENTRY_DST%" (
		rmdir /s /q "%VBOX_ENTRY_DST%" >NUL
	)
	move "%VBOX_ENTRY_SRC%" "%VBOX_ENTRY_DST%" >NUL
	echo.
	echo VirtualBox Guest Additions updated.
) else (
	echo.
	echo Unable to locate setup. Please check if the Guest
	echo Additions CD image is inserted ^(Devices -^> Insert
	echo Guest Additions CD image...^)
)


REM ------------------------------------
REM -                                  -
REM - Exit                             -
REM -                                  -
REM ------------------------------------
:exit

REM Wait for keystroke
if "%IS_INTERACTIVE%" == "false" (
	echo.
	echo Hit any key to close.
	pause >NUL 2>&1
)

REM Exit local environment scope
endlocal

REM Exit gracefully
exit /b
