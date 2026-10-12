@echo off
echo Starting VouchDesk...

start "VouchDesk Server" cmd /k "cd /d %~dp0server && npm run dev"
timeout /t 2 /nobreak >nul
start "VouchDesk Client" cmd /k "cd /d %~dp0client && npm run dev"

echo Both windows launched.
