@echo off
chcp 65001 >nul 2>&1
title Seagull Compatibility Test
echo.
echo ============================================
echo   Seagull Compatibility Test v20.0
echo ============================================
echo.

set pass=0
set fail=0

echo [Test 1] Windows version...
ver | findstr /i "10\." >nul 2>&1
if %errorlevel% equ 0 (
    echo   PASS - Windows 10/11
    set /a pass+=1
) else (
    ver | findstr /i "6\." >nul 2>&1
    if %errorlevel% equ 0 (
        echo   PASS - Windows 7/8
        set /a pass+=1
    ) else (
        echo   WARN - Unknown Windows version
        set /a fail+=1
    )
)

echo [Test 2] PowerShell available...
where powershell.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo   PASS - PowerShell found
    set /a pass+=1
) else (
    echo   FAIL - PowerShell not found
    set /a fail+=1
)

echo [Test 3] PowerShell version...
for /f "tokens=*" %%i in ('powershell -Command "$PSVersionTable.PSVersion.Major" 2^>nul') do set PS_VER=%%i
if defined PS_VER (
    echo   PASS - PowerShell %PS_VER%
    set /a pass+=1
) else (
    echo   WARN - Cannot determine PS version
    set /a fail+=1
)

echo [Test 4] User profile exists...
if exist "%USERPROFILE%" (
    echo   PASS - %USERPROFILE%
    set /a pass+=1
) else (
    echo   FAIL - USERPROFILE not found
    set /a fail+=1
)

echo [Test 5] .claude directory...
if exist "%USERPROFILE%\.claude" (
    echo   PASS - .claude exists
    set /a pass+=1
) else (
    echo   WARN - .claude not found (will be created)
    set /a pass+=1
)

echo [Test 6] deploy.ps1 exists...
if exist "%~dp0seagull-files\deploy.ps1" (
    echo   PASS - deploy.ps1 found
    set /a pass+=1
) else (
    echo   FAIL - deploy.ps1 not found
    set /a fail+=1
)

echo [Test 7] CLAUDE.md exists...
if exist "%~dp0seagull-files\claude-config-bundle\CLAUDE.md" (
    echo   PASS - CLAUDE.md found
    set /a pass+=1
) else (
    echo   FAIL - CLAUDE.md not found
    set /a fail+=1
)

echo [Test 8] system-prompt.md exists...
if exist "%~dp0seagull-files\claude-config-bundle\system-prompt.md" (
    echo   PASS - system-prompt.md found
    set /a pass+=1
) else (
    echo   FAIL - system-prompt.md not found
    set /a fail+=1
)

echo [Test 9] Execution policy...
powershell -Command "Get-ExecutionPolicy" 2>nul | findstr /i "Restricted" >nul 2>&1
if %errorlevel% equ 0 (
    echo   WARN - Execution policy is Restricted
    echo         Will use -ExecutionPolicy Bypass
) else (
    echo   PASS - Execution policy OK
    set /a pass+=1
)

echo [Test 10] Write permission...
echo test > "%USERPROFILE%\.claude\test_write.tmp" 2>nul
if %errorlevel% equ 0 (
    del "%USERPROFILE%\.claude\test_write.tmp" >nul 2>&1
    echo   PASS - Can write to .claude
    set /a pass+=1
) else (
    echo   WARN - Cannot write to .claude
    echo         Try running as administrator
    set /a fail+=1
)

echo.
echo ============================================
echo   Results: %pass% passed, %fail% failed
if %fail% gtr 0 (
    echo.
    echo   Some tests failed. Check issues above.
) else (
    echo.
    echo   All tests passed! Run 启动.bat to deploy.
)
echo ============================================
echo.
pause
