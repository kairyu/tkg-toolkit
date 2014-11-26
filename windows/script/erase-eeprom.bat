@echo off
cd %~dp0
set PROGRAMMER=..\dfu-programmer
set TARGET=atmega32u4
set "HEX=%~1"
if not exist %HEX% goto :END
@echo on
%PROGRAMMER% %TARGET% erase
%PROGRAMMER% %TARGET% flash %HEX%
%PROGRAMMER% %TARGET% flash-eeprom empty.eep
:END
%PROGRAMMER% %TARGET% start
@echo off
pause
