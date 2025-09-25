Param(
  [string]$TargetRoot = "C:\Users\macie\Documents\GitHub\HeliosPulse",
  [string]$GitRemote  = "",   # e.g., https://github.com/KID6767/HeliosPulse.git
  [string]$GitBranch  = "main"
)

$ErrorActionPreference = "Stop"
Write-Host "== HeliosPulse Installer ==" -ForegroundColor Cyan

# 1) pick latest .b64
$latestB64 = Get-ChildItem -Path $TargetRoot -Filter *.b64 -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $latestB64) { Write-Host "[X] No .b64 package in $TargetRoot" -ForegroundColor Red; exit 1 }
Write-Host "[OK] Using package: $($latestB64.Name)" -ForegroundColor Green

# 2) decode -> zip, unpack
$ZipOut = Join-Path $TargetRoot "HeliosPulse_AllInOne.zip"
$base64 = Get-Content $latestB64.FullName -Raw
[IO.File]::WriteAllBytes($ZipOut, [Convert]::FromBase64String($base64))
Expand-Archive -Path $ZipOut -DestinationPath $TargetRoot -Force
Remove-Item $ZipOut -Force
Write-Host "[OK] Unpacked to: $TargetRoot" -ForegroundColor Green

# 3) git (optional)
Set-Location $TargetRoot
if (!(Test-Path ".git")) {
  git init | Out-Null
  if ($GitRemote) { git remote add origin $GitRemote | Out-Null }
  Write-Host "[OK] Git initialized" -ForegroundColor Green
}
git add -A
try { git commit -m "HeliosPulse: install/update" | Out-Null; Write-Host "[OK] Commit" -ForegroundColor Green } catch { Write-Host "[i] Nothing to commit" -ForegroundColor Yellow }
if ($GitRemote) { try { git push -u origin $GitBranch } catch { git push origin $GitBranch } }

# 4) ask for URLs
$newApp = Read-Host "Paste NEW WebApp URL (https://script.google.com/.../exec) or Enter to skip"
$thread = Read-Host "Paste Alliance Forum Thread URL (optional) or Enter to skip"

# 5) patch files
$configPath = Join-Path $TargetRoot "Skrypty\Config.json"
$userJsPath = Join-Path $TargetRoot "Skrypty\HeliosPulse.user.js"

if ($newApp -and ($newApp -match '^https://script\.google\.com/macros/')) {
  if (Test-Path $configPath) {
    (Get-Content $configPath -Raw) -replace '"WEBAPP_URL":\s*".*?"', ('"WEBAPP_URL": "'+$newApp+'"') | Set-Content $configPath -Encoding UTF8
    Write-Host "[OK] Config.json updated" -ForegroundColor Green
  }
  if (Test-Path $userJsPath) {
    (Get-Content $userJsPath -Raw) -replace 'WEBAPP_URL:\s*".*?"', ('WEBAPP_URL: "'+$newApp+'"') | Set-Content $userJsPath -Encoding UTF8
    Write-Host "[OK] HeliosPulse.user.js updated (WEBAPP_URL)" -ForegroundColor Green
  }
} else { Write-Host "[i] WEBAPP_URL not changed" -ForegroundColor Yellow }

if ($thread -and ($thread -match '^https?://')) {
  if (Test-Path $userJsPath) {
    (Get-Content $userJsPath -Raw) -replace 'ALLIANCE_THREAD_URL:\s*".*?"', ('ALLIANCE_THREAD_URL: "'+$thread+'"') | Set-Content $userJsPath -Encoding UTF8
    Write-Host "[OK] HeliosPulse.user.js updated (ALLIANCE_THREAD_URL)" -ForegroundColor Green
  }
}

# 6) verify
$ok1 = Test-Path $configPath
$ok2 = Test-Path $userJsPath
Write-Host "-------------------------------------"
Write-Host ("[OK] Config.json present: " + $ok1)
Write-Host ("[OK] HeliosPulse.user.js present: " + $ok2)
Write-Host "[OK] Done"
Write-Host "-------------------------------------"
