@echo off
cd %~dp0
set bat=%~n0
reflash.bat ..\common\hex\%bat:~8%.hex %*
