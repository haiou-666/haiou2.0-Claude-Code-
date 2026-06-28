@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\seagull-files\deploy.ps1" -Restore
