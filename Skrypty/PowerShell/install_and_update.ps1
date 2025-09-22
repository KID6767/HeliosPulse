Param(
  [string]$Base64Path = "C:\Users\macie\Documents\GitHub\HeliosPulse\HeliosPulse_AllInOne_Final.b64",
  [string]$TargetRoot = "C:\Users\macie\Documents\GitHub\HeliosPulse",
  [string]$GitRemote = "", # e.g., https://github.com/User/HeliosPulse.git
  [string]$GitBranch = "main",
  [string]$CommitMsg = "HeliosPulse: auto update"
)

$ErrorActionPreference = "Stop"

Write-Host "== HeliosPulse Installer ==" -ForegroundColor Cyan

# 1) Verify the existence of the b64 file
if (!(Test-Path $Base64Path)) {
  Write-Host "[X] File not found: $Base64Path" -ForegroundColor Red
  exit 1
} else {
  Write-Host "[OK] Base64 package found" -ForegroundColor Green
}

# 2) Decode b64 to zip
$ZipOut = Join-Path $TargetRoot "HeliosPulse_AllInOne.zip"
if (!(Test-Path $TargetRoot)) {
  New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
}
Write-Host "[...] Decoding base64 to zip"
$base64 = Get-Content $Base64Path -Raw
[IO.File]::WriteAllBytes($ZipOut, [Convert]::FromBase64String($base64))

# 3) Unpack the zip file
Write-Host "[...] Unpacking the package..."
Expand-Archive -Path $ZipOut -DestinationPath $TargetRoot -Force
Remove-Item $ZipOut -Force
Write-Host "[OK] Unpacked to: $TargetRoot" -ForegroundColor Green

# 4) Git initialization / add / commit / push
Set-Location $TargetRoot
if (!(Test-Path ".git")) {
  git init | Out-Null
  if ($GitRemote) {
    git remote add origin $GitRemote | Out-Null
  }
  Write-Host "[OK] Git repository initialized" -ForegroundColor Green
}

git add -A
try {
  git commit -m $CommitMsg | Out-Null
  Write-Host "[OK] Commit executed successfully" -ForegroundColor Green
} catch {
  Write-Host "[i] No new changes to commit" -ForegroundColor Yellow
}

if ($GitRemote) {
  try {
    git push -u origin $GitBranch
    Write-Host "[OK] Pushed to $GitRemote ($GitBranch)" -ForegroundColor Green
  } catch {
    git push origin $GitBranch
  }
}

# 5) Checklist
Write-Host "-------------------------------------"
Write-Host "[OK] Base64 unpacked"
Write-Host "[OK] Git repository updated"
Write-Host "-------------------------------------"

# 6) Prompt for a new WebApp URL
$newUrl = Read-Host "Please paste the NEW WebApp URL from Google Apps Script (e.g., https://script.google.com/.../exec)"

if ($newUrl -and ($newUrl -match '^https://script\.google\.com/macros/')) {
  $configPath = Join-Path $TargetRoot "Skrypty\Config.json"
  $userJsPath = Join-Path $TargetRoot "Skrypty\HeliosPulse.user.js"

  if (Test-Path $configPath) {
    (Get-Content $configPath -Raw) -replace '"WEBAPP_URL":\s*".*?"', '"WEBAPP_URL": "'+$newUrl+'"' | Set-Content $configPath -Encoding UTF8
    Write-Host "[OK] Config.json updated" -ForegroundColor Green
  }
  if (Test-Path $userJsPath) {
    (Get-Content $userJsPath -Raw) -replace 'WEBAPP_URL:\s*".*?"', 'WEBAPP_URL: "'+$newUrl+'"' | Set-Content $userJsPath -Encoding UTF8
    Write-Host "[OK] HeliosPulse.user.js updated" -ForegroundColor Green
  }
} else {
  Write-Host "[i] URL not changed." -ForegroundColor Yellow
}
