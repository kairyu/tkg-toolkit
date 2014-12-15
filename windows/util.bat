::: _   _            _              _ _    _ _
:::| |_| | ____ _   | |_ ___   ___ | | | _(_) |_
:::| __| |/ / _` |__| __/ _ \ / _ \| | |/ / | __|
:::| |_|   < (_| |__| || (_) | (_) | |   <| | |_
::: \__|_|\_\__, |   \__\___/ \___/|_|_|\_\_|\__|
:::         |___/
:::                                       UTILITY

@echo off
setlocal enableextensions enabledelayedexpansion
set CURPATH=%~dp0
set BINPATH=%CURPATH%\bin
set CONFPATH=%CURPATH%\conf
set SCRIPTPATH=%CURPATH%\script
set FWPATH=%CURPATH%\..\common\firmware
set MISCPATH=%CURPATH%\..\common\misc

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
echo Keyboard to manipulate:
echo.
echo	 Name:		%KBDNAME%
echo	 MCU:		%KBDMCU%
echo	 Bootloader:	%KBDBL%
echo	 Firmware:	%KBDFW%
if not "%KBDCOM%" == "" (
echo	 SerialPort:	%KBDCOM%
)

:SELECTUTILITY
echo.
echo Select utility:
echo.
echo	 1. Dump EEPROM
echo	 2. Erase EEPROM
echo.
:ENTERUTILITYNUMBER
set "INPUT="
set /p INPUT="Please enter a number: "
if "!INPUT!" == "q" ( goto :EOF )
set /a INPUT="!INPUT! + 0"
if !INPUT! lss 1 ( goto :ENTERUTILITYNUMBER )
if !INPUT! gtr 2 ( goto :ENTERUTILITYNUMBER )
set /a UTLNUMBER="!INPUT! + 0"

:SWITCHUTILITY
if "%UTLNUMBER%" == "1" (
	goto :DUMPEEPROM
) else if "%UTLNUMBER%" == "2" (
	goto :ERASEEEPROM
) else (
	goto :EOF
)

:DUMPEEPROM
echo.
if "%KBDBL%" == "atmel_dfu" (
	set TARGET=%KBDMCU%
	set "HEX=%FWPATH%\%KBDFW%"
	call "%SCRIPTPATH%\dump_eeprom-dfu" "%CURPATH%\eeprom.bin"
) else if "%KBDBL%" == "lufa_dfu" (
	set TARGET=%KBDMCU%
	set "HEX="
	call "%SCRIPTPATH%\dump_eeprom-dfu" "%CURPATH%\eeprom.bin"
) else if "%KBDBL%" == "arduino" (
	set PARTNO=%KBDMCU%
	set COM=%KBDCOM%
	call "%SCRIPTPATH%\dump_eeprom-arduino" "%CURPATH%\eeprom.bin"
) else (
	echo Unsupported bootloader
)
echo.
goto :END

:ERASEEEPROM
echo.
if "%KBDBL%" == "atmel_dfu" (
	set TARGET=%KBDMCU%
	call "%SCRIPTPATH%\reflash-dfu" "%FWPATH%\%KBDFW%" "%MISCPATH%\empty.eep"
) else if "%KBDBL%" == "lufa_dfu" (
	set TARGET=%KBDMCU%
	call "%SCRIPTPATH%\reflash-dfu" "%MISCPATH%\empty.eep"
) else if "%KBDBL%" == "arduino" (
	set PARTNO=%KBDMCU%
	set COM=%KBDCOM%
	call "%SCRIPTPATH%\reflash-arduino" "%MISCPATH%\empty.eep"
) else (
	echo Unsupported bootloader
)
echo.
goto :END

:END
pause
