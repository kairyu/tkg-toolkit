@echo off
setlocal enabledelayedexpansion
set SCRIPT=%~nx0
set CURPATH=%~dp0
set BINPATH=%CURPATH%\..\bin
set SCRIPTPATH=%CURPATH%\..\script
set EXEC=%BINPATH%\zadic

echo Looking for bootloader, please reset your device ...
cd %BINPATH%
set STARTTIME=%TIME: =0%
set /a REMIND=0
set /a STARTTIME=(1%STARTTIME:~0,2%-100)*360000 + (1%STARTTIME:~3,2%-100)*6000 + (1%STARTTIME:~6,2%-100)*100 + (1%STARTTIME:~9,2%-100)
:WAIT
set ENDTIME=%TIME: =0%
set /a ENDTIME=(1%ENDTIME:~0,2%-100)*360000 + (1%ENDTIME:~3,2%-100)*6000 + (1%ENDTIME:~6,2%-100)*100 + (1%ENDTIME:~9,2%-100)
set /a DURATION=%ENDTIME%-%STARTTIME%
if %REMIND% LSS 1 (
	if %DURATION% GTR 3000 (
		set /a REMIND=1
		echo Did you forget to press the reset button?
	)
)
zadic --dryrun --usealldevice --noprompt --vid %1 --pid %2 >nul 2>nul
if "%ERRORLEVEL%"=="0" (
	goto :INSTALL
)
if "%ERRORLEVEL%"=="2" (
	goto :NONEEDTOINSTALL
)
goto :WAIT

:INSTALL
echo Found bootloader, start to install driver. (this might take a few minutes)
zadic --usealldevice --noprompt --vid %1 --pid %2 >nul 2>nul
echo Installation completed.
goto :END

:NONEEDTOINSTALL
echo Found bootloader, however driver is already installed.
echo Installation completed. (nothing to install)
goto :END

:END
endlocal
pause
exit

