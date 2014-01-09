@echo off
cd %~dp0
set PROGRAMMER=dfu-programmer
set TARGET=atmega32u4
set HEX=hex\%1.hex
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
%PROGRAMMER% %TARGET% erase
%PROGRAMMER% %TARGET% flash %HEX%
@echo off
if "%EEP%" == "" goto :END
@echo on
%PROGRAMMER% %TARGET% flash-eeprom "%EEP%"
:END
%PROGRAMMER% %TARGET% start
@echo off
pause