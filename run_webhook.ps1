# Install / run scripts for kad_yandexFORMs_leads webhook service (variant B).
#
# We bypass python-dotenv for BITRIX_SESSION_JSON because the embedded JSON
# contains '{', ':' and '"' which python-dotenv refuses to parse reliably.
# Instead we read the session file and export it as an env var in this
# PowerShell wrapper before launching uvicorn / installing the service.

$ProjectRoot = 'D:\11. 2KAD_Soft\My projects\kad_yandexFORMs_leads'
$VenvPython = Join-Path $ProjectRoot '.venv\Scripts\python.exe'
$SessionFile = 'D:\11. 2KAD_Soft\8. 2KAD_bitrix\.bitrix-session.json'
$LogDir = 'C:\2kad-yandexFORMs_leads-logs'

# Build env for uvicorn. Read session JSON once, embed as string.
$env:BITRIX_BASE_URL = 'https://bitrix.a2kad.ru'
$env:BITRIX_FUNNEL_ID = '3'
$env:BITRIX_RESPONSIBLE_ID = '1'
$env:APP_ENV = 'production'
$env:LOG_LEVEL = 'info'
$env:PORT = '8765'

if (Test-Path $SessionFile) {
    $env:BITRIX_SESSION_JSON = (Get-Content -Raw -Path $SessionFile -Encoding UTF8)
    Write-Host "Loaded BITRIX_SESSION_JSON from $SessionFile ($($env:BITRIX_SESSION_JSON.Length) chars)"
} else {
    Write-Error "Session file not found: $SessionFile"
    exit 1
}

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$LogFile = Join-Path $LogDir 'webhook.log'

Write-Host "Starting uvicorn on http://127.0.0.1:$env:PORT -> $LogFile"
& $VenvPython -m uvicorn app.main:app --host 0.0.0.0 --port $env:PORT 2>&1 | Tee-Object -FilePath $LogFile
