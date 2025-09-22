$ErrorActionPreference="Stop"

$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$B64 = Join-Path $Here "HeliosPulse_AllInOne.b64"
$Zip = Join-Path $Here "HeliosPulse_Full.zip"

Write-Host "Dekodowanie paczki base64..."
$base64 = Get-Content $B64 -Raw
[IO.File]::WriteAllBytes($Zip,[Convert]::FromBase64String($base64))

Write-Host "Rozpakowywanie paczki..."
Expand-Archive -Path $Zip -DestinationPath $Here -Force

Remove-Item $Zip -Force
Write-Host "✅ Gotowe! Wszystkie pliki zostały wypakowane do $Here"
