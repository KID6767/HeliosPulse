Param([Parameter(Mandatory=$true)][string]$Base64Path,[Parameter(Mandatory=$true)][string]$ZipOut,[Parameter(Mandatory=$true)][string]$ExtractTo)
$ErrorActionPreference="Stop"
$base64=Get-Content $Base64Path -Raw
[IO.File]::WriteAllBytes($ZipOut,[Convert]::FromBase64String($base64))
Expand-Archive -Path $ZipOut -DestinationPath $ExtractTo -Force
