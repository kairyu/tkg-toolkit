@echo off
cd %~dp0
set bat=%~n0
reflash.bat ..\common\firmware\%bat:~8%.hex %*
