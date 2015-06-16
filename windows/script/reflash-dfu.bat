@echo off
setlocal enabledelayedexpansion
set SCRIPT=%~nx0
set CURPATH=%~dp0
set BINPATH=%CURPATH%\..\bin
set SCRIPTPATH=%CURPATH%\..\script
set EXEC=%BINPATH%\dfu-programmer
if "%TARGET%" == "" set TARGET=atmega32u4
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
echo Waiting for Bootloader...
set STARTTIME=%TIME: =0%
set /a REMIND=0
set /a STARTTIME=(1%STARTTIME:~0,2%-100)*360000 + (1%STARTTIME:~3,2%-100)*6000 + (1%STARTTIME:~6,2%-100)*100 + (1%STARTTIME:~9,2%-100)
:WAIT
set ENDTIME=%TIME: =0%
set /a ENDTIME=(1%ENDTIME:~0,2%-100)*360000 + (1%ENDTIME:~3,2%-100)*6000 + (1%ENDTIME:~6,2%-100)*100 + (1%ENDTIME:~9,2%-100)
set /a DURATION=%ENDTIME%-%STARTTIME%
if %REMIND% LSS 1 (
	if %DURATION% GTR 3000 (
		set /a REMIND=1
		echo Did you forget to press the reset button?
	)
)
"%EXEC%" %TARGET% get >nul 2>nul
if not "%ERRORLEVEL%"=="0" (
	goto :WAIT
)
if not "%HEX%" == "" (
	echo Erasing...
	"%EXEC%" %TARGET% erase --force
	echo Reflashing HEX file...
	"%EXEC%" %TARGET% flash "%HEX%"
)
if not "%EEP%" == "" (
	echo Reflashing EEP file...
	"%EXEC%" %TARGET% flash-eeprom --force "%EEP%"
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
			copy /y "%HEX%" "%HEX_ORIG%"
			if not "%ERRORLEVEL%" == "0" (
				echo Fail^^!
			)
			if "%ERRORLEVEL%" == "0" (
				echo Success^^!
			)
		)
	)
)
"%EXEC%" %TARGET% reset
goto :END

:USAGE
@echo Usage: %SCRIPT% hex [hex^|eep]
goto :END

:END
exit /b %EXITCODE%
