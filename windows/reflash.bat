::: _   _            _              _ _    _ _
:::| |_| | ____ _   | |_ ___   ___ | | | _(_) |_
:::| __| |/ / _` |__| __/ _ \ / _ \| | |/ / | __|
:::| |_|   < (_| |__| || (_) | (_) | |   <| | |_
::: \__|_|\_\__, |   \__\___/ \___/|_|_|\_\_|\__|
:::         |___/
:::                                       REFLASH

@echo off
setlocal enableextensions enabledelayedexpansion
set CURPATH=%~dp0
set BINPATH=%CURPATH%\bin
set CONFPATH=%CURPATH%\conf
set SCRIPTPATH=%CURPATH%\script
set FWPATH=%CURPATH%\..\common\firmware

:WELCOME
cls
for /f "delims=: tokens=*" %%a in ('findstr /b ::: "%~f0"') do @echo(%%a
echo.

:CHECKCONFIGFILE
set CONFFILE=%CONFPATH%\default.ini
if not exist "%CONFFILE%" (
	echo.
	echo Config file does not exist, please run SETUP first
	echo.
	goto :END
)

:LOADCONFIGFILE
for /f "delims=" %%a in ('type "%CONFFILE%"') do (
	for /f "delims== tokens=1-2" %%b in ("%%a") do (
		set KEY=%%b
		set VALUE=%%c
		set VALUE=!VALUE:"=!
		set !KEY!=!VALUE!
	)
)
set KBDNAME=%Name%
set KBDMCU=%MCU%
set KBDBL=%Bootloader%
set KBDFW=%Firmware%
if not "%SerialPort%" == "" (
	set KBDCOM=%SerialPort%
) else (
	set "KBDCOM="
)
echo.
echo Keyboard to reflash:
echo.
echo	 Name:		%KBDNAME%
echo	 MCU:		%KBDMCU%
echo	 Bootloader:	%KBDBL%
echo	 Firmware:	%KBDFW%
if not "%KBDCOM%" == "" (
echo	 SerialPort:	%KBDCOM%
)

:GETARGUMENT
set "ARG=%~1"
:GETARGUMENTLOOP
shift
if not "%~1" == "" (
	set "ARG=!ARG! %1"
	goto :GETARGUMENTLOOP
)
if not "%ARG%" == "" (
	for %%a in ("%ARG%") do set ARGEXT=%%~xa
)

:SELECTMANIPULATION
echo.
echo Manipulation:
echo.
if "%ARG%" == "" (
	set MANIP=1
	echo  Reflash default firmware: ..\common\firmware\%KBDFW%
	goto :CONFIRM
)
if exist "%ARG%" (
	if "%ARGEXT%" == ".hex" (
		set MANIP=2
		echo  Reflash firmware: "%ARG%"
		goto :CONFIRM
	)
	if "%ARGEXT%" == ".eep" (
		set MANIP=3
		echo  Reflash eeprom: "%ARG%"
		goto :CONFIRM
	)
)
echo  Wrong argument: "%ARG%"
echo.
goto :END

:CONFIRM
echo.
set /p INPUT="Do you want to continue? [Y/n] "
if "!INPUT!" == "q" ( goto :EOF )
if "!INPUT!" == "n" ( goto :EOF )

:SETARGUMENTS
set "ARG1="
set "ARG2="
if "%MANIP%" == "1" (
	set "ARG1=%FWPATH%\%KBDFW%"
) else if "%MANIP%" == "2" (
	set "ARG1=%ARG%"
) else if "%MANIP%" == "3" (
	if "%KBDBL%" == "atmel_dfu" (
		set "ARG1=%FWPATH%\%KBDFW%"
		set "ARG2=%ARG%"
	) else (
		set "ARG1=%ARG%"
	)
) else (
	goto :EOF
)

:REFLASH
echo.
if "%KBDBL%" == "atmel_dfu" (
	set TARGET=%KBDMCU%
	if "%ARG2%" == "" (
		call "%SCRIPTPATH%\reflash-dfu" "%ARG1%"
	) else (
		call "%SCRIPTPATH%\reflash-dfu" "%ARG1%" "%ARG2%"
	)
) else if "%KBDBL%" == "lufa_dfu" (
	set TARGET=%KBDMCU%
	call "%SCRIPTPATH%\reflash-dfu" "%ARG1%"
) else if "%KBDBL%" == "arduino" (
	set PARTNO=%KBDMCU%
	set COM=%KBDCOM%
	call "%SCRIPTPATH%\reflash-arduino" "%ARG1%"
) else (
	echo Unsupported bootloader
	echo.
	goto :END
)
echo.

:END
endlocal
pause
