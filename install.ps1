$ErrorActionPreference="Stop"

# Ścieżki
$Here = "C:\Users\macie\Documents\GitHub\HeliosPulse"
$B64 = Join-Path $Here "HeliosPulse_Full.b64"
$Zip = Join-Path $Here "HeliosPulse_Full.zip"

# Dekodowanie base64 → zip
Write-Host "Dekodowanie base64 do ZIP..."
$base64 = Get-Content $B64 -Raw
[IO.File]::WriteAllBytes($Zip,[Convert]::FromBase64String($base64))

# Rozpakowanie do katalogu
Write-Host "Rozpakowywanie paczki..."
Expand-Archive -Path $Zip -DestinationPath $Here -Force

# Usuwanie tymczasowego zipa
Remove-Item $Zip -Force
Write-Host "Gotowe! Wszystkie pliki zostały wypakowane do $Here"
