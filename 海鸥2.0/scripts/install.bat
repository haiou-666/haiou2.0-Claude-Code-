@echo off
chcp 65001 >nul 2>&1
echo.
echo ============================================
echo   Seagull Installer v18.1
echo ============================================
echo.

REM Check if running as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Not running as admin. Some features may require admin.
    echo.
)

REM Get script directory
set "SCRIPT_DIR=%~dp0"

REM Check if PowerShell is available
powershell -Command "Write-Host 'PowerShell OK'" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] PowerShell not found. Please install PowerShell 5.1+
    pause
    exit /b 1
)

REM Check PowerShell version
for /f "tokens=*" %%i in ('powershell -Command "$PSVersionTable.PSVersion.Major"') do set PS_MAJOR=%%i
if %PS_MAJOR% lss 5 (
    echo [!] PowerShell 5.0+ required (current: %PS_MAJOR%)
    pause
    exit /b 1
)

echo [*] PowerShell version: %PS_MAJOR%
echo.

REM Run deploy
echo Running deploy...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%seagull-files\deploy.ps1"

if %errorlevel% equ 0 (
    echo.
    echo [+] Installation successful!
    echo.
    echo Next steps:
    echo   1. Restart Claude Code
    echo   2. Type "在吗" or "海鸥" to test
    echo.
) else (
    echo.
    echo [-] Installation failed. Check errors above.
    echo.
)

pause
