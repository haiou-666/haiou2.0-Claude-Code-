@echo off
chcp 65001 >nul 2>&1
echo.
echo ============================================
echo   Seagull Restore v18.1
echo ============================================
echo.

REM Get script directory
set "SCRIPT_DIR=%~dp0"

REM Check if PowerShell is available
powershell -Command "Write-Host 'PowerShell OK'" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] PowerShell not found. Please install PowerShell 5.1+
    pause
    exit /b 1
)

echo This will restore configuration from the latest backup.
echo.
set /p confirm="Continue? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Cancelled.
    pause
    exit /b 0
)

echo.
echo Running restore...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%seagull-files\deploy.ps1" -Restore

if %errorlevel% equ 0 (
    echo.
    echo [+] Restore complete!
    echo.
) else (
    echo.
    echo [-] Restore failed. Check errors above.
    echo.
)

pause
