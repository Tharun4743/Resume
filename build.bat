@echo off
setlocal EnableDelayedExpansion

title Building Resume PDF...
echo =======================================================
echo              Building Resume PDF
echo =======================================================
echo.

cd /d "%~dp0"

:: Check if XeLaTeX is operational
set "USE_ENGINE="
where xelatex >nul 2>&1
if %ERRORLEVEL% equ 0 (
    xelatex --version >nul 2>&1
    if !ERRORLEVEL! equ 0 set "USE_ENGINE=xelatex"
)

if not defined USE_ENGINE (
    if exist "C:\MiKTeX\miktex\bin\x64\xelatex.exe" (
        set "PATH=C:\MiKTeX\miktex\bin\x64;!PATH!"
        xelatex --version >nul 2>&1
        if !ERRORLEVEL! equ 0 set "USE_ENGINE=xelatex"
    )
)

if not defined USE_ENGINE (
    if exist "%~dp0bin\tectonic.exe" (
        set "USE_ENGINE=tectonic"
    )
)

if "%USE_ENGINE%"=="xelatex" goto :compile_xelatex
if "%USE_ENGINE%"=="tectonic" goto :compile_tectonic

echo [ERROR] Neither XeLaTeX nor Tectonic engine could be run.
echo If using MiKTeX, ensure Windows Smart App Control is set to Evaluation or Off.
echo.
pause
exit /b 1

:compile_xelatex
echo [INFO] Compiling with XeLaTeX [MiKTeX]...
echo.
xelatex -synctex=1 -interaction=nonstopmode resume.tex
set "BUILD_EXIT=%ERRORLEVEL%"
goto :report_result

:compile_tectonic
echo [INFO] Compiling with Tectonic engine...
echo.
"%~dp0bin\tectonic.exe" -X compile resume.tex --synctex
set "BUILD_EXIT=%ERRORLEVEL%"
goto :report_result

:report_result
echo.
if %BUILD_EXIT% equ 0 (
    echo =======================================================
    echo [SUCCESS] resume.pdf built successfully!
    echo =======================================================
    if exist "resume.pdf" (
        for %%F in ("resume.pdf") do (
            echo Output File : %%~fF
            echo File Size   : %%~zF bytes
            echo Last Updated: %%~tF
        )
    )
) else (
    echo =======================================================
    echo [ERROR] Build failed with exit code: %BUILD_EXIT%
    echo =======================================================
    if exist "resume.log" echo Review resume.log for details.
)

echo.
pause
