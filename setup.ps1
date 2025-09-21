Param([string]$TargetRoot="C:\Users\macie\Documents\GitHub\SANDBOX\Sojusz\HeliosPulse_Full")
$ErrorActionPreference="Stop"
$Here=Split-Path -Parent $MyInvocation.MyCommand.Path
$Zip=Join-Path $Here "HeliosPulse_Full.zip"
$B64=Join-Path $Here "HeliosPulse_Full.b64"
$base64=Get-Content $B64 -Raw
[IO.File]::WriteAllBytes($Zip,[Convert]::FromBase64String($base64))
if(!(Test-Path $TargetRoot)){New-Item -ItemType Directory -Force -Path $TargetRoot|Out-Null}
Expand-Archive -Path $Zip -DestinationPath $TargetRoot -Force
