@echo off
REM Double-click this file to rebuild photos\manifest.js
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0generate-manifest.ps1"
echo.
pause
