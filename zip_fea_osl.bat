@echo off
setlocal

git describe --tags --abbrev=0 > ver.txt
set /p version=<ver.txt
rm ver.txt
IF %ERRORLEVEL% NEQ 0 goto :error_exit

echo "Generating FeaOSL-%version%.zip"

set out="build\FeaOSL-%version%.zip"
7z a -aoa -tzip %out% "*.osl" "*.ui" "README.md"
IF %ERRORLEVEL% NEQ 0 goto :error_exit

rem Exit cleanly.
endlocal
goto :EOF

rem Exit with error and code.
:error_exit
echo.
echo An error occured, exit code : %=ExitCode%
endlocal
exit /b %ERRORLEVEL%