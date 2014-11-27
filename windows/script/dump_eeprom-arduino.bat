@echo off
setlocal enabledelayedexpansion
set CURPATH=%~dp0
set BINPATH=%CURPATH%\..\bin
set SCRIPTPATH=%CURPATH%\..\script
set EXEC=%BINPATH%\avrdude
if "%PARTNO%" == "" set PARTNO=atmega32u4
set PROGRAMMER=avr109
set OUTPUT=%~1

call "%SCRIPTPATH%\wait_serial_port" %COM%
if not "%ERRORLEVEL%" == "0" ( goto :END )

echo Dumping...
set PORT=%COM%
"%EXEC%" -p%PARTNO% -c%PROGRAMMER% -P%PORT% -Ueeprom:r:"%OUTPUT%":r

if not "%ERRORLEVEL%" == "0" (
	echo Fail^^!
	set EXITCODE=%ERRORLEVEL%
)
if "%ERRORLEVEL%" == "0" (
	echo Success^^!
	set EXITCODE=%ERRORLEVEL%
)

:END
exit /b %EXITCODE%
