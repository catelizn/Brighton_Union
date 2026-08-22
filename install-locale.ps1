# Copies Brighton Union localization files into a QBCore server.
param([string]$ServerPath)

if (-not $ServerPath) {
    $ServerPath = Read-Host 'Server data folder (e.g. ...\txData\QBCore_8A0510.base)'
}

$pack = Join-Path $PSScriptRoot 'locale-pack'

Get-ChildItem -LiteralPath $pack -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($pack.Length + 1)
    $dest = Join-Path $ServerPath $rel
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
}

Write-Host 'Brighton Union localization installed.'
