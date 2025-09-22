Param(
  [string]$Base64Path = "C:\Users\macie\Documents\GitHub\HeliosPulse\HeliosPulse_AllInOne_Final.b64",
  [string]$TargetRoot = "C:\Users\macie\Documents\GitHub\HeliosPulse"
)

$ErrorActionPreference = "Stop"

Write-Host "== HeliosPulse Installer ==" -ForegroundColor Cyan

# 1) Find .b64 file
if (!(Test-Path $Base64Path)) {
  Write-Host "[X] File not found: $Base64Path" -ForegroundColor Red
  exit 1
} else {
  Write-Host "[OK] Base64 package found" -ForegroundColor Green
}

# 2) Decode base64 -> zip
$ZipOut = Join-Path $TargetRoot "HeliosPulse_AllInOne.zip"
$base64 = Get-Content $Base64Path -Raw
[IO.File]::WriteAllBytes($ZipOut, [Convert]::FromBase64String($base64))
Write-Host "[OK] Decoded to zip" -ForegroundColor Green

# 3) Unpack
Expand-Archive -Path $ZipOut -DestinationPath $TargetRoot -Force
Remove-Item $ZipOut -Force
Write-Host "[OK] Package unpacked to $TargetRoot" -ForegroundColor Green

# 4) Ask for new URL
$newUrl = Read-Host "Paste NEW WebApp URL (or press Enter to skip)"

if ($newUrl -and ($newUrl -match '^https://script\.google\.com/macros/')) {
  $configPath = Join-Path $TargetRoot "Skrypty\Config.json"
  $userJsPath = Join-Path $TargetRoot "Skrypty\HeliosPulse.user.js"

  if (Test-Path $configPath) {
    (Get-Content $configPath -Raw) -replace '"WEBAPP_URL":\s*".*?"', ('"WEBAPP_URL": "' + $newUrl + '"') |
      Set-Content $configPath -Encoding UTF8
    Write-Host "[OK] Config.json updated" -ForegroundColor Green
  }

  if (Test-Path $userJsPath) {
    (Get-Content $userJsPath -Raw) -replace 'WEBAPP_URL:\s*".*?"', ('WEBAPP_URL: "' + $newUrl + '"') |
      Set-Content $userJsPath -Encoding UTF8
    Write-Host "[OK] HeliosPulse.user.js updated" -ForegroundColor Green
  }
} else {
  Write-Host "[i] URL not changed" -ForegroundColor Yellow
}

Write-Host "== DONE ==" -ForegroundColor Cyan
