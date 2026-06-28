@echo off
chcp 65001 >nul 2>&1
title Seagull Deploy

REM ========== FIX: Get script directory safely ==========
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%seagull-files\deploy.ps1"

REM ========== FIX: Check if deploy.ps1 exists ==========
if not exist "%PS_SCRIPT%" (
    echo.
    echo [!] Error: deploy.ps1 not found
    echo     Expected location: %PS_SCRIPT%
    echo.
    echo     Make sure the folder structure is correct:
    echo     - seagull-files\deploy.ps1
    echo     - seagull-files\claude-config-bundle\
    echo.
    pause
    exit /b 1
)

REM ========== FIX: Check if PowerShell exists ==========
where powershell.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] PowerShell not found
    echo     Please install PowerShell 5.1+
    echo     Download: https://aka.ms/powershell
    echo.
    pause
    exit /b 1
)

REM ========== FIX: Run deploy ==========
echo.
echo Starting Seagull Deploy...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

REM ========== FIX: Check exit code ==========
if %errorlevel% neq 0 (
    echo.
    echo [!] Deploy may have issues
    echo     Try running as administrator
    echo.
    pause
)
