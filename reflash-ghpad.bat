@echo off
cd %~dp0
set bat=%~n0
reflash.bat hex\%bat:~8%.hex %*