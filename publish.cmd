@echo off
REM Double-clickable / no-flags-needed wrapper around publish.ps1.
REM Runs with -ExecutionPolicy Bypass for THIS PROCESS ONLY -- it does not
REM change any system or user execution-policy setting. Use this instead of
REM `.\publish.ps1` directly if your machine's policy is Restricted (the
REM "running scripts is disabled on this system" error).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish.ps1" %*
