# backup-live-build.ps1
# ============================================================
# Byte-exact backup of the CURRENTLY LIVE Firebase Hosting build.
# Run BEFORE deploying a new build so you can always roll back.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\backup-live-build.ps1 `
#     -ProjectId stock-count-app-c381c -OutDir C:\backups\live -Keep 5
#
# Defaults: ProjectId = stock-count-app-c381c (prod), OutDir =
# C:\xampp\htdocs\<ProjectId>-live-backup-<timestamp>, Keep = 5.
# Each file is fetched from BOTH <project>.web.app and <project>.firebaseapp.com
# and must be byte-identical (SHA-256). README.txt + zip written per backup;
# backups beyond -Keep are pruned. Do NOT use query-string cache busters -
# Firebase Hosting SPA rewrite returns index.html for any URL with a query.
# ============================================================

param(
  [string]$ProjectId = 'stock-count-app-c381c',
  [string]$OutDir = '',
  [int]$Keep = 5,
  [int]$MaxFiles = 0
)

$ErrorActionPreference = 'Stop'

if (-not $OutDir) {
  $stamp = Get-Date -Format 'yyyy-MM-dd-HHmmss'
  $OutDir = Join-Path 'C:\xampp\htdocs' "$ProjectId-live-backup-$stamp"
}

# Standard Flutter web release file set (stable across Flutter 3.x).
# If a new Flutter version adds files, add them here.
$files = @(
  'index.html','main.dart.js','flutter_bootstrap.js','flutter_service_worker.js',
  'flutter.js','manifest.json','version.json','favicon.png',
  'icons/Icon-maskable-512.png','icons/Icon-maskable-192.png',
  'icons/Icon-512.png','icons/Icon-192.png',
  'canvaskit/wimp.wasm','canvaskit/wimp.js','canvaskit/wimp.js.symbols',
  'canvaskit/skwasm.wasm','canvaskit/skwasm.js','canvaskit/skwasm.js.symbols',
  'canvaskit/skwasm_heavy.wasm','canvaskit/skwasm_heavy.js','canvaskit/skwasm_heavy.js.symbols',
  'canvaskit/canvaskit.wasm','canvaskit/canvaskit.js','canvaskit/canvaskit.js.symbols',
  'canvaskit/chromium/canvaskit.wasm','canvaskit/chromium/canvaskit.js','canvaskit/chromium/canvaskit.js.symbols',
  'assets/NOTICES','assets/FontManifest.json','assets/AssetManifest.bin.json','assets/AssetManifest.bin',
  'assets/shaders/stretch_effect.frag','assets/shaders/ink_sparkle.frag',
  'assets/packages/cupertino_icons/assets/CupertinoIcons.ttf','assets/fonts/MaterialIcons-Regular.otf'
)

$hostA = "https://$ProjectId.web.app"
$hostB = "https://$ProjectId.firebaseapp.com"

Write-Output "Backing up live build: $hostA  ->  $OutDir"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$count = 0; $ok = 0; $failed = @()
foreach ($rel in $files) {
  if ($MaxFiles -gt 0 -and $count -ge $MaxFiles) { break }
  $count++
  $dest = Join-Path $OutDir ($rel -replace '/', '\')
  $dir = Split-Path $dest -Parent
  if ($dir -ne $OutDir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

  & curl.exe -sS -f --connect-timeout 15 --max-time 120 -H 'Accept-Encoding: identity' -o $dest "$hostA/$rel"
  if ($LASTEXITCODE -ne 0) { $failed += "$rel (fetch A failed)"; continue }
  & curl.exe -sS -f --connect-timeout 15 --max-time 120 -H 'Accept-Encoding: identity' -o "$dest.tmp" "$hostB/$rel"
  if ($LASTEXITCODE -ne 0) { Remove-Item $dest -Force -ErrorAction SilentlyContinue; $failed += "$rel (fetch B failed)"; continue }
  $h1 = (Get-FileHash -Algorithm SHA256 -Path $dest).Hash
  $h2 = (Get-FileHash -Algorithm SHA256 -Path "$dest.tmp").Hash
  Remove-Item "$dest.tmp" -Force
  if ($h1 -eq $h2) { $ok++ } else { Remove-Item $dest -Force; $failed += "$rel (host mismatch)" }
}

$total = (Get-ChildItem $OutDir -Recurse -File | Measure-Object Length -Sum).Sum

$ver = ''
$vp = Join-Path $OutDir 'version.json'
if (Test-Path $vp) { $ver = (Get-Content $vp -Raw) }
$readme = @"
Live build backup - $ProjectId
===============================
Backup time : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Project     : $ProjectId
Source      : $hostA  (verified byte-identical against $hostB)
Files       : $ok verified of $count (SHA-256)
Size        : $([math]::Round($total / 1MB, 2)) MB
version.json: $ver

RESTORE / ROLLBACK:
  1. Copy all files/folders into build\web\  (xcopy /E /I /Y <this folder> build\web)
  2. npx firebase-tools@15.25.1 deploy --only hosting --project $ProjectId

NOTE: Flutter builds are NOT byte-reproducible. This download is the only
faithful copy of the build that was live at backup time.
"@
Set-Content -Path (Join-Path $OutDir 'README.txt') -Value $readme -Encoding UTF8

$zip = "$OutDir.zip"
Compress-Archive -Path (Join-Path $OutDir '*') -DestinationPath $zip -Force

$parent = Split-Path $OutDir -Parent
$old = @(Get-ChildItem -Path $parent -Directory -Filter "$ProjectId-live-backup-*" | Sort-Object Name -Descending | Select-Object -Skip $Keep)
foreach ($o in $old) { Remove-Item $o.FullName -Recurse -Force; Remove-Item "$($o.FullName).zip" -Force -ErrorAction SilentlyContinue }

Write-Output "Backup complete: $ok/$count files verified -> $OutDir"
Write-Output "Zip: $zip"
if ($failed.Count -gt 0) {
  Write-Output 'Failures:'
  $failed | ForEach-Object { Write-Output "  $_" }
  exit 1
}
