@echo off
setlocal enabledelayedexpansion
set SCRIPT=%~nx0
set EXEC=%~dp0\dfu-programmer
if "%TARGET%" == "" set TARGET=atmega32u4
set "HEX="
set "HEX_ORIG="
set "EEP="

set "ARG1=%~1"
if "%ARG1%" == "" goto :USAGE
if not exist %ARG1% goto :USAGE
set /a ARGS=1
shift

set "ARG2=%~1"
:ARG2_LOOP
shift
if not "%~1" == "" (
	set "ARG2=%ARG2% %1"
	goto :ARG2_LOOP
)
if not "%ARG2%" == "" set /a ARGS=2

if "!ARGS!" == "1" (
	set HEX=%ARG1%
	goto :REFLASH
)
if "!ARGS!" == "2" (
	if not exist %ARG2% goto :USAGE
	for %%i in (%ARG2%) do set ARG2_EXT=%%~xi
	if "!ARG2_EXT!" == ".hex" (
		set HEX=%ARG2%
		set HEX_ORIG=%ARG1%
		goto :REFLASH
	)
	if "!ARG2_EXT!" == ".eep" (
		set HEX=%ARG1%
		set EEP=%ARG2%
		goto :REFLASH
	)
)
goto :USAGE

:REFLASH
echo Waiting for Bootloader...
:WAIT
%EXEC% %TARGET% get >nul 2>nul
if not "%ERRORLEVEL%"=="0" (
	goto :WAIT
)
echo Erasing...
%EXEC% %TARGET% erase
echo Reflashing hex...
%EXEC% %TARGET% flash %HEX%
if not "%EEP%" == "" (
	echo Reflashing eep...
	%EXEC% %TARGET% flash-eeprom "%EEP%"
)
if not "%ERRORLEVEL%" == "0" (
	echo Fail^^!
)
if "%ERRORLEVEL%" == "0" (
	echo Success^^!
	if not "%HEX_ORIG%" == "" (
		set "INPUT="
		set /p INPUT=Replace existing hex with the new one? [y/N]
		if "!INPUT!" == "y" (
			copy /y %HEX% %HEX_ORIG%
			if not "%ERRORLEVEL%" == "0" (
				echo Fail^^!
			)
			if "%ERRORLEVEL%" == "0" (
				echo Success^^!
			)
		)
	)
)
%EXEC% %TARGET% reset
goto :END

:USAGE
@echo Usage: %SCRIPT% hex [hex^|eep]
goto :END

:END
endlocal
:: pause
