@echo off
REM CMD wrapper for run_webhook.ps1 — for use from nssm / scheduled tasks.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "D:\11. 2KAD_Soft\My projects\kad_yandexFORMs_leads\run_webhook.ps1"
