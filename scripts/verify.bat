@echo off
chcp 65001 >nul 2>&1
echo.
echo ============================================
echo   Seagull Verifier v18.1
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

echo Running verification...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%seagull-files\deploy.ps1" -Verify

if %errorlevel% equ 0 (
    echo.
    echo [+] Verification passed!
    echo.
) else (
    echo.
    echo [-] Verification failed. Run deploy first.
    echo.
)

pause
