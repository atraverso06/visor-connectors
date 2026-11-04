<#
.SYNOPSIS
    Packs the connectors' catalog for a release (ADR 0029): connectors-<version>.zip with one folder per recipe, and
    catalog.json with its version, the engine it needs and the zip's SHA-256. Both go in the same GitHub release, which
    Visor reads at .../releases/latest/download/.

.EXAMPLE
    ./build/pack.ps1 -Version 2026.11.2
#>
param(
    [string]$Source = (Join-Path $PSScriptRoot '..\connectors'),
    [string]$Out = (Join-Path $PSScriptRoot '..\artifacts\connectors'),
    [string]$Version = (Get-Date -Format 'yyyy.M.d'),
    [int]$Engine = 0 # 0: the highest engine any recipe needs
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$null = [Version]::Parse($Version) # a version Visor can compare: numbers and dots

New-Item -ItemType Directory -Force $Out | Out-Null
$zipPath = Join-Path (Resolve-Path $Out) "connectors-$Version.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath }

# Only the recipes' folders (connector.json and what sits next to it), at the zip's top level, with "/" in the names
# as zip files expect (Windows PowerShell's Compress-Archive writes "\").
$folders = Get-ChildItem $Source -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'connector.json') }
if (-not $folders) { throw "No recipes in $Source" }
# The catalog needs the newest engine any of its recipes needs: an older Visor keeps the catalog it has.
if ($Engine -le 0) {
    $Engine = ($folders | ForEach-Object {
        $text = Get-Content -Raw (Join-Path $_.FullName 'connector.json')
        if ($text -match '"engine"\s*:\s*(\d+)') { [int]$Matches[1] } else { 1 }
    } | Measure-Object -Maximum).Maximum
}

$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($folder in $folders) {
        foreach ($file in Get-ChildItem $folder.FullName -File -Recurse) {
            $name = $folder.Name + '/' + $file.FullName.Substring($folder.FullName.Length + 1).Replace('\', '/')
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $name) | Out-Null
        }
    }
}
finally {
    $zip.Dispose()
}

$manifest = [ordered]@{
    version = $Version
    engine  = $Engine
    zip     = Split-Path $zipPath -Leaf
    sha256  = (Get-FileHash $zipPath -Algorithm SHA256).Hash
}
# UTF-8 without a byte order mark: plain JSON.
[System.IO.File]::WriteAllText((Join-Path (Resolve-Path $Out) 'catalog.json'), ($manifest | ConvertTo-Json), (New-Object System.Text.UTF8Encoding $false))
"Packed $($folders.Count) recipes (engine $Engine) into $zipPath"
