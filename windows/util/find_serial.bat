@echo off
setlocal enabledelayedexpansion
set FIRST=1
set "PREV="
set "COM="
echo | set /p=Finding...

:LOOP
set "LIST="
for /f "DELIMS=" %%a in ('mode') do (
	set OUT=%%a
	set "TEST=!OUT:COM=!"
	if not "!TEST!"=="!OUT!" (
		set PORT=!OUT:*COM=!
		set PORT=!PORT::=!
		set "LIST=!LIST! !PORT!"
	)
)
if not "%FIRST%" == "1" (
	for %%a in (%LIST%) do (
		if not "%%a" == "" (
			set FOUND=0
			for %%b in (%PREV%) do (
				if "!FOUND!" == "0" if %%a == %%b set FOUND=1
			)
			if "!FOUND!" == "0" (
				set COM=COM%%a
				goto :END
			)
		)
	)
)
set FIRST=0
set PREV=%LIST%
goto :LOOP

:END
echo !COM!
copy /y NUL _!COM! >NUL
pause
