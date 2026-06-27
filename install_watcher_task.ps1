# Install / uninstall the kad_yandexFORMs_leads folder-watcher scheduled task.
#
# Runs every 5 minutes. Logs to:
#   %LOCALAPPDATA%\kad_yandexFORMs_leads\watcher.log
#
# Run as Administrator (PowerShell), or via Mavis with the user's full PS.

$TaskName = 'kad_yandexFORMs_leads_folder_watcher'
$ScriptPath = 'D:\11. 2KAD_Soft\My projects\kad_yandexFORMs_leads\folder_watcher.py'
$PythonExe = 'python.exe'
$LogPath = Join-Path $env:LOCALAPPDATA 'kad_yandexFORMs_leads\watcher.log'

# Ensure log dir exists.
$logDir = Split-Path $LogPath -Parent
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

# Build the action: python -u <script> >> <log> 2>&1
$Action = New-ScheduledTaskAction -Execute $PythonExe -Argument "-u `"$ScriptPath`" >> `"$LogPath`" 2>&1"
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes 5) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

# Settings: don't wake machine, run only when AC, allow start if missed, no battery stop.
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -DontStopOnIdleEnd `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
    -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)

$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# Remove existing if present (idempotent re-install).
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

Register-ScheduledTask -TaskName $TaskName `
    -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal `
    -Description 'Polls Bitrix24 funnel 3 for new deals and creates matching folders under the leads/projects roots per 2KAD process.' `
    | Out-Null

# Smoke run now to ensure it actually works.
& $PythonExe -u $ScriptPath
Write-Host "Installed task '$TaskName'. Run 'Get-ScheduledTask $TaskName' to verify."
