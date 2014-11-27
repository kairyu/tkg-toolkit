@echo off
setlocal enabledelayedexpansion
set COM=%~1

if "%COM%"=="" (
	for %%f in (*) do (
		set "FILE=%%f"
		set "TEST=!FILE:COM=!"
		if not "!TEST!" == "!FILE!" (
			set "COM=!FILE:_=!"
			goto :WAIT_COM
		)
	)
	echo COM not specified
	set EXITCODE=1
	goto :END
)

:WAIT_COM
echo Waiting for %COM% ...
:WAIT_COM_LOOP
for /f "DELIMS=" %%a in ('mode %COM%') do set OUT=%%a
set "TEST=%OUT::=%"
if not "%TEST%" == "%OUT%" goto :FOUND_COM
goto :WAIT_COM_LOOP

:FOUND_COM
set EXITCODE=0
echo %COM% is ready

:END
exit /b %EXITCODE%
