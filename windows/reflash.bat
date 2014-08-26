@echo off
cd %~dp0
set EXEC=bin\dfu-programmer
set TARGET=atmega32u4
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
@echo on
%EXEC% %TARGET% erase
%EXEC% %TARGET% flash %HEX%
@echo off
if "%EEP%" == "" goto :END
@echo on
%EXEC% %TARGET% flash-eeprom "%EEP%"
:END
%EXEC% %TARGET% start
@echo off
pause
