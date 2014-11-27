::: _   _            _              _ _    _ _
:::| |_| | ____ _   | |_ ___   ___ | | | _(_) |_
:::| __| |/ / _` |__| __/ _ \ / _ \| | |/ / | __|
:::| |_|   < (_| |__| || (_) | (_) | |   <| | |_
::: \__|_|\_\__, |   \__\___/ \___/|_|_|\_\_|\__|
:::         |___/
:::                                         SETUP

@echo off
setlocal enableextensions enabledelayedexpansion
set CURPATH=%~dp0
set BINPATH=%CURPATH%\bin
set CONFPATH=%CURPATH%\conf
set SCRIPTPATH=%CURPATH%\script
set KBDFILE=%CURPATH%\..\common\config\keyboards.json
set KBD=type "%KBDFILE%"
set JQ="%BINPATH%\jq"

:WELCOME
cls
for /f "delims=: tokens=*" %%a in ('findstr /b ::: "%~f0"') do @echo(%%a
echo.

:SELECTYOURKEYBOARD
echo.
echo Select your keyboard:
echo.
for /f "usebackq delims=" %%a in (`%KBD% ^| %JQ% "length"`) do set "NUMOFKBD=%%a"
set /a "INDEX=1"
for /f "usebackq delims=" %%a in (`%KBD% ^| %JQ% ".[].name"`) do (
	set "NAME=%%a"
	set "NUMBER= !INDEX!"
	echo  !NUMBER:~-2!. !NAME:"=!
	set /a INDEX="!INDEX! + 1"
)
echo.
:ENTERKEYBOARDNUMBER
set "INPUT="
set /p INPUT="Please enter a number: "
if "!INPUT!" == "q" ( goto :EOF )
set /a INPUT="!INPUT! + 0"
if !INPUT! leq 0 ( goto :ENTERKEYBOARDNUMBER )
if !INPUT! gtr %NUMOFKBD% ( goto :ENTERKEYBOARDNUMBER )
set /a KBDINDEX="!INPUT! - 1"

:SHOWKEYBOARDCONFIG
for /f "usebackq delims=" %%a in (`%KBD% ^| %JQ% ".[%KBDINDEX%].name"`) do set "KBDNAME=%%a"
for /f "usebackq delims=" %%a in (`%KBD% ^| %JQ% ".[%KBDINDEX%].mcu"`) do set "KBDMCU=%%a"
for /f "usebackq delims=" %%a in (`%KBD% ^| %JQ% ".[%KBDINDEX%].bootloader | join(\"^, \")"`) do set "KBDBL=%%a"
for /f "usebackq delims=" %%a in (`%KBD% ^| %JQ% ".[%KBDINDEX%].firmware"`) do set "KBDFW=%%a"
echo.
echo	 Name:		%KBDNAME:"=%
echo	 MCU:		%KBDMCU:"=%
echo	 Bootloader:	%KBDBL:"=%
echo	 Firmware:	%KBDFW:"=%
echo.

:CONFIRMRESELECT
set "INPUT="
set /p INPUT="Do you want to reselect? [y/N] "
if "!INPUT!" == "q" ( goto :EOF )
if "!INPUT!" == "y" ( goto :SELECTYOURKEYBOARD )

:SELECTBOOTLOADER
echo.
echo Select bootloader of your keyboard:
echo.
for /f "usebackq delims=" %%a in (`%KBD% ^| %JQ% ".[%KBDINDEX%].bootloader | length"`) do set "NUMOFBL=%%a"
set /a "INDEX=1"
for /f "usebackq delims=" %%a in (`%KBD% ^| %JQ% ".[%KBDINDEX%].bootloader[]"`) do (
	set "NAME=%%a"
	echo  !INDEX!. !NAME:"=!
	set /a INDEX="!INDEX! + 1"
)
echo.
:ENTERBOOTLOADERNUMBER
set "INPUT=1"
for /f %%a in ('copy /Z "%~dpf0" nul') do set "ASCII_13=%%a"
set /p INPUT="Please enter a number: 1!ASCII_13!Please enter a number: "
if "!INPUT!" == "q" ( goto :EOF )
set /a INPUT="!INPUT! + 0"
if !INPUT! leq 0 ( goto :ENTERBOOTLOADERNUMBER )
if !INPUT! gtr %NUMOFBL% ( goto :ENTERBOOTLOADERNUMBER )
set /a BLINDEX="!INPUT! - 1"
for /f "usebackq delims=" %%a in (`%KBD% ^| %JQ% ".[%KBDINDEX%].bootloader[%BLINDEX%]"`) do set "KBDBL=%%a"

:ARDUINOBOOTLOADER
set "KBDCOM="
if %KBDBL% == "arduino" (
	echo.
	echo Need to setup a serial port for arduino bootloader
	set /p INPUT="Do you want to setup automatically? [Y/n] "
	if "!INPUT!" == "q" ( goto :EOF )
	if "!INPUT!" == "n" ( goto :ENTERSERIALPORT )
	goto :FINDSERIALPORT
)
goto :SAVECONFIG

:ENTERSERIALPORT
echo.
:ENTERSERIALPORTLOOP
set /p INPUT="Please enter a serial port number: COM"
if "!INPUT!" == "q" ( goto :EOF )
set /a INPUT="!INPUT! + 0"
if !INPUT! leq 0 ( goto :ENTERSERIALPORTLOOP )
set KBDCOM="COM!INPUT!"
goto :SAVECONFIG

:FINDSERIALPORT
echo.
echo | set /p="Please reset your arduino ... "
call "%SCRIPTPATH%\find_serial_port"
set KBDCOM=COM%ERRORLEVEL%
if "%KBDCOM%" == "COM0" ( goto :END )
echo found %KBDCOM%
goto :SAVECONFIG

:SAVECONFIG
set CONFFILE=%CONFPATH%\default.ini
mkdir "%CONFPATH%" 2>NUL
echo Name=%KBDNAME%> "%CONFFILE%"
echo MCU=%KBDMCU%>> "%CONFFILE%"
echo Bootloader=%KBDBL%>> "%CONFFILE%"
echo Firmware=%KBDFW%>> "%CONFFILE%"
if not "%KBDCOM%" == "" (
	echo SerialPort="%KBDCOM%">> "%CONFFILE%"
)
echo.
echo Your config has been saved
echo.

:END
endlocal
pause
