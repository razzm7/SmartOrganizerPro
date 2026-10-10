@echo off
setlocal
cd /d "%~dp0"
title Smart Organizer Pro
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0SmartOrganizerPro.ps1"
if errorlevel 1 (
  echo.
  echo Smart Organizer Pro reported an error. See the message above.
)
echo.
echo Smart Organizer Pro has closed.
pause
