@echo off
setlocal enabledelayedexpansion
set CURPATH=%~dp0
set BINPATH=%CURPATH%\..\bin
set EXEC=%BINPATH%\dfu-programmer
if "%TARGET%" == "" set TARGET=atmega32u4
set OUTPUT=%~1

echo Waiting for Bootloader...
:WAIT
"%EXEC%" %TARGET% get >nul 2>nul
if not "%ERRORLEVEL%"=="0" (
	goto :WAIT
)

if not "%HEX%" == "" (
	echo Erasing...
	"%EXEC%" %TARGET% erase
)

echo Dumping...
"%EXEC%" %TARGET% dump-eeprom>%OUTPUT%

if not "%HEX%" == "" (
	echo Reflashing...
	"%EXEC%" %TARGET% flash "%HEX%"
)

if not "%ERRORLEVEL%" == "0" (
	echo Fail^^!
	set EXITCODE=%ERRORLEVEL%
)
if "%ERRORLEVEL%" == "0" (
	echo Success^^!
	set EXITCODE=%ERRORLEVEL%
)

"%EXEC%" %TARGET% reset

:END
exit /b %EXITCODE%
