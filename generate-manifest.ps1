# =====================================================================
#  Helensiyas Productions - photo manifest generator
#  Scans every sub-folder inside the "photos" folder that sits next to
#  this script. Each sub-folder becomes a slideshow collection, and the
#  folder name becomes its title. Writes the result to photos\manifest.js
#
#  Run it whenever you add, remove or rename photos/folders.
#  Easiest way: double-click "run-manifest.bat".
# =====================================================================

$ErrorActionPreference = "Stop"

$base = $PSScriptRoot
if (-not $base) { $base = (Get-Location).Path }

$root = Join-Path $base "photos"
$exts = ".jpg", ".jpeg", ".png", ".webp", ".gif", ".avif"

if (-not (Test-Path $root)) {
    Write-Host "Could not find a 'photos' folder next to this script." -ForegroundColor Red
    Write-Host "Put this file in the same folder as your index.html and the 'photos' folder."
    exit 1
}

function Esc([string]$s) { $s -replace '\\', '\\' -replace '"', '\"' }

Write-Host "Scanning $root ..." -ForegroundColor Cyan
Write-Host ""

$cols = @()
Get-ChildItem -Path $root -Directory | Sort-Object Name | ForEach-Object {
    $folder = $_.Name
    $files = Get-ChildItem -Path $_.FullName -File |
        Where-Object { $exts -contains $_.Extension.ToLower() } |
        Sort-Object Name
    if ($files.Count -gt 0) {
        $title = $folder -replace '_', ' '
        $items = $files | ForEach-Object { '"photos/' + (Esc $folder) + '/' + (Esc $_.Name) + '"' }
        $cols += '{"name":"' + (Esc $title) + '","photos":[' + ($items -join ',') + ']}'
        Write-Host ("  {0,-30} {1} photos" -f $folder, $files.Count)
    }
}

$js  = "window.GALLERY = [" + ($cols -join ",") + "];" + [Environment]::NewLine
$out = Join-Path $root "manifest.js"
Set-Content -Path $out -Value $js -Encoding UTF8

Write-Host ""
if ($cols.Count -gt 0) {
    Write-Host ("Done. Wrote photos\manifest.js with {0} collection(s)." -f $cols.Count) -ForegroundColor Green
} else {
    Write-Host "No image folders found. Add sub-folders with images inside 'photos' and run again." -ForegroundColor Yellow
}
