@echo off
setlocal enabledelayedexpansion
cd %~dp0
set EXEC=bin\avrdude
set PARTNO=atmega32u4
set PROGRAMMER=avr109
set "HEX=%~1"
if not exist %HEX% goto :END
shift
set "EEP=%~1"
shift
:LOOP
if not "%~1" == "" (
	set "EEP=%EEP% %1"
	shift
	goto :LOOP
)

for %%f in (*) do (
	set "FILE=%%f"
	set "TEST=!FILE:COM=!"
	if not "!TEST!"=="!FILE!" (
		set "COM=!FILE!"
		echo Waiting for !COM!...
		goto :COM
	)
)
echo COM not specified
goto END

:COM
for /f "DELIMS=" %%a in ('mode %COM%') do set OUT=%%a
set "TEST=!OUT::=!"
if not "!TEST!"=="!OUT!" goto FLASH
goto COM

:FLASH
echo %COM% is ready
set PORT=%COM%
if "%EEP%"=="" (
	echo Reflashing HEX file...
	%EXEC% -p%PARTNO% -c%PROGRAMMER% -P%PORT% -Uflash:w:"%HEX%":i
)
if not "%EEP%"=="" (
	echo Reflashing EEP file...
	%EXEC% -p%PARTNO% -c%PROGRAMMER% -P%PORT% -Ueeprom:w:"%EEP%":i
)
if "%ERRORLEVEL%"=="0" (
	echo Success^^!
)
if not "%ERRORLEVEL%"=="0" (
	echo Fail^^!
)

:END
pause
