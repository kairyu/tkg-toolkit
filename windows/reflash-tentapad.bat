@echo off
pushd "%cd%"
cd %~dp0
set bat=%~n0
set TARGET=atmega32u2
.\bin\reflash-dfu.bat ..\common\firmware\%bat:~8%.hex %*
popd
pause
