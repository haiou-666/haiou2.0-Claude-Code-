@echo off
chcp 65001 >nul 2>&1
echo.
echo ============================================
echo   Seagull Tester v18.1
echo ============================================
echo.

set "CLAUDE_DIR=%USERPROFILE%\.claude"
set pass=0
set fail=0

echo [Test 1] CLAUDE.md exists...
if exist "%CLAUDE_DIR%\CLAUDE.md" (
    echo   PASS
    set /a pass+=1
) else (
    echo   FAIL
    set /a fail+=1
)

echo [Test 2] system-prompt.md exists...
if exist "%CLAUDE_DIR%\system-prompt.md" (
    echo   PASS
    set /a pass+=1
) else (
    echo   FAIL
    set /a fail+=1
)

echo [Test 3] config.toml exists...
if exist "%CLAUDE_DIR%\config.toml" (
    echo   PASS
    set /a pass+=1
) else (
    echo   FAIL
    set /a fail+=1
)

echo [Test 4] settings.json exists...
if exist "%CLAUDE_DIR%\settings.json" (
    echo   PASS
    set /a pass+=1
) else (
    echo   FAIL
    set /a fail+=1
)

echo.
echo Results: %pass% passed, %fail% failed
if %fail% gtr 0 (
    echo WARNING: Some files missing! Run install.bat first.
) else (
    echo All tests passed!
)
echo.
pause
