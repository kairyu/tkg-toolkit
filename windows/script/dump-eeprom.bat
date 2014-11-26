@echo off
cd %~dp0
set PROGRAMMER=..\dfu-programmer
set TARGET=atmega32u4
set "HEX=%~1"
if not exist %HEX% goto :END
@echo on
%PROGRAMMER% %TARGET% erase
%PROGRAMMER% %TARGET% dump-eeprom > eeprom.bin
%PROGRAMMER% %TARGET% flash %HEX%
:END
%PROGRAMMER% %TARGET% start
@echo off
pause
