@echo off
chcp 65001 >nul 2>&1
title Seagull Uninstall

REM ========== FIX: Get script directory safely ==========
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%seagull-files\deploy.ps1"

REM ========== FIX: Check if deploy.ps1 exists ==========
if not exist "%PS_SCRIPT%" (
    echo.
    echo [!] Error: deploy.ps1 not found
    echo     Expected location: %PS_SCRIPT%
    echo.
    pause
    exit /b 1
)

REM ========== FIX: Check if PowerShell exists ==========
where powershell.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] PowerShell not found
    echo.
    pause
    exit /b 1
)

REM ========== FIX: Confirmation ==========
echo.
echo This will remove Seagull configuration.
echo.
set /p confirm="Continue? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Cancelled.
    pause
    exit /b 0
)

REM ========== FIX: Run uninstall ==========
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -Uninstall

if %errorlevel% neq 0 (
    echo.
    echo [!] Uninstall may have issues
    echo.
    pause
)
