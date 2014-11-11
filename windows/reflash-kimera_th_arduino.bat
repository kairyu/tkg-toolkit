@echo off
pushd "%cd%"
cd %~dp0
set bat=%~n0
set bat=%bat:_arduino=%
set PARTNO=atmega32u4
.\bin\reflash-arduino.bat ..\common\firmware\%bat:~8%.hex %*
popd
pause
