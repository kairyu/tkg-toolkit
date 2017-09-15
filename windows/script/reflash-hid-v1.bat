@echo off
setlocal enabledelayedexpansion
set SCRIPT=%~nx0
set CURPATH=%~dp0
set BINPATH=%CURPATH%\..\bin
set SCRIPTPATH=%CURPATH%\..\script
set EXEC=%BINPATH%\hid_bootloader_cli
if "%MMCU%" == "" set MMCU=atmega32u4
set "HEX="
set "EEP="

set "ARG1=%~1"
:ARG1_LOOP
shift
if not "%~1" == "" (
	set "ARG1=%ARG1% %1"
	goto :ARG1_LOOP
)
if "%ARG1%" == "" goto :USAGE
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

:REFLASH
if "%EEP%" == "" (
	echo Reflashing HEX file...
	"%EXEC%" -mmcu=%MMCU% -w -f "%HEX%"
)
if not "%EEP%" == "" (
	echo Reflashing EEP file...
	"%EXEC%" -mmcu=%MMCU% -w -e "%EEP%"
)
if not "%ERRORLEVEL%" == "0" (
	echo Fail^^!
	set EXITCODE=%ERRORLEVEL%
)
if "%ERRORLEVEL%" == "0" (
	echo Success^^!
	set EXITCODE=%ERRORLEVEL%
)
goto :END

:USAGE
@echo Usage: %SCRIPT% [hex^|eep]
goto :END

:END
exit /b %EXITCODE%
