@echo off
setlocal enabledelayedexpansion
set SCRIPT=%~nx0
set CURPATH=%~dp0
set BINPATH=%CURPATH%\..\bin
set SCRIPTPATH=%CURPATH%\..\script
set EXEC=%BINPATH%\avrdude
if "%PARTNO%" == "" set PARTNO=atmega32u4
set PROGRAMMER=avr109
set "HEX="
set "HEX_ORIG="
set "EEP="

set "ARG1=%~1"
if "%ARG1%" == "" goto :USAGE
if not exist "%ARG1%" goto :USAGE
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

if "%ARGS%" == "1" (
	if not exist "%ARG1%" goto :USAGE
	for %%i in ("%ARG1%") do set ARG1_EXT=%%~xi
	if "!ARG1_EXT!" == ".hex" (
		set "HEX=%ARG1%"
		goto :REFLASH
	)
	if "!ARG1_EXT!" == ".eep" (
		set "EEP=%ARG1%"
		goto :REFLASH
	)
	goto :USAGE
)
if "%ARGS%" == "2" (
	if not exist "%ARG2%" goto :USAGE
	for %%i in ("%ARG2%") do set ARG2_EXT=%%~xi
	if "!ARG2_EXT!" == ".hex" (
		set "HEX=%ARG2%"
		set "HEX_ORIG=%ARG1%"
		goto :REFLASH
	)
	if "!ARG2_EXT!" == ".eep" (
		set "HEX=%ARG1%"
		set "EEP=%ARG2%"
		goto :REFLASH
	)
	goto :USAGE
)
goto :USAGE

:REFLASH
call "%SCRIPTPATH%\wait_serial_port" %COM%
if not "%ERRORLEVEL%" == "0" ( goto :END )
set PORT=%COM%
if "%EEP%" == "" (
	echo Reflashing HEX file...
	"%EXEC%" -p%PARTNO% -c%PROGRAMMER% -P%PORT% -Uflash:w:"%HEX%":i
)
if not "%EEP%" == "" (
	echo Reflashing EEP file...
	"%EXEC%" -p%PARTNO% -c%PROGRAMMER% -P%PORT% -Ueeprom:w:"%EEP%":i
)
if not "%ERRORLEVEL%" == "0" (
	echo Fail^^!
	set EXITCODE=%ERRORLEVEL%
)
if "%ERRORLEVEL%" == "0" (
	echo Success^^!
	set EXITCODE=%ERRORLEVEL%
	if not "%HEX_ORIG%" == "" (
		set "INPUT="
		set /p INPUT=Replace existing HEX with the new one? [y/N]
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
goto :END

:USAGE
@echo Usage: %SCRIPT% hex [hex^|eep]
goto :END

:END
exit /b %EXITCODE%
