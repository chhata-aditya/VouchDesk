@echo off
echo Starting VoucherDesk...

start "VoucherDesk Server" cmd /k "cd /d %~dp0server && npm run dev"
timeout /t 2 /nobreak >nul
start "VoucherDesk Client" cmd /k "cd /d %~dp0client && npm run dev"

echo Both windows launched.
