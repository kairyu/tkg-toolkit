@echo off
setlocal enabledelayedexpansion
set FIRST=1
set "COM="
set "PREVLIST="

:FIND_COM_LOOP
set "PORTLIST="
for /f "DELIMS=" %%a in ('mode') do (
	set OUTPUT=%%a
	set "TEST=!OUTPUT:COM=!"
	if not "!TEST!"=="!OUTPUT!" (
		set PORT=!OUTPUT:*COM=!
		set PORT=!PORT::=!
		set "PORTLIST=!PORTLIST! !PORT!"
	)
)
if not "%FIRST%" == "1" (
	for %%a in (!PORTLIST!) do (
		if not "%%a" == "" (
			set FOUND=0
			for %%b in (!PREVLIST!) do (
				if "!FOUND!" == "0" if %%a == %%b set FOUND=1
			)
			if "!FOUND!" == "0" (
				set COM=%%a
				goto :FOUND_COM
			)
		)
	)
)
set FIRST=0
set PREVLIST=%PORTLIST%
goto :FIND_COM_LOOP

:FOUND_COM
exit /b %COM%
