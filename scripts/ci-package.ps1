param(
  [Parameter(Mandatory = $true)]
  [string]$ArtifactName
)

$ErrorActionPreference = 'Stop'

$binary = Get-ChildItem -LiteralPath "lib" -Recurse -File |
  Where-Object { $_.Name -eq 'opencode_manager' -or $_.Name -eq 'opencode_manager.exe' } |
  Sort-Object FullName |
  Select-Object -First 1

if (-not $binary) {
  throw 'Unable to find compiled opencode_manager binary under lib.'
}

$distRoot = Join-Path 'dist' $ArtifactName
New-Item -ItemType Directory -Force -Path $distRoot | Out-Null

Copy-Item -LiteralPath $binary.FullName -Destination $distRoot

if ($IsWindows) {
  $sqliteSearchRoots = @(
    'C:\ProgramData\chocolatey\lib\sqlite\tools',
    'C:\tools\sqlite',
    'C:\tools\sqlite3',
    $env:ChocolateyInstall,
    'C:\Program Files\OpenSSL',
    'C:\Program Files\OpenSSL-Win64',
    'C:\Program Files\OpenSSL-Win32'
  ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
  $runtimeDlls = $sqliteSearchRoots |
    ForEach-Object { Get-ChildItem -LiteralPath $_ -Recurse -File -Include sqlite3.dll,libssl*.dll,libcrypto*.dll -ErrorAction SilentlyContinue } |
    Sort-Object Name, @{ Expression = { if ($_.FullName -match 'x64|win64|OpenSSL-Win64') { 0 } else { 1 } } }, FullName |
    Group-Object Name |
    ForEach-Object { $_.Group | Select-Object -First 1 }
  foreach ($dll in $runtimeDlls) {
    Copy-Item -LiteralPath $dll.FullName -Destination $distRoot -Force
  }
} else {
  chmod +x (Join-Path $distRoot $binary.Name)
}

if (Test-Path -LiteralPath 'README.md') {
  Copy-Item -LiteralPath 'README.md' -Destination $distRoot
}
if (Test-Path -LiteralPath 'LICENSE') {
  Copy-Item -LiteralPath 'LICENSE' -Destination $distRoot
}

$archive = Join-Path 'dist' ($ArtifactName + '.zip')
if (Test-Path -LiteralPath $archive) {
  Remove-Item -LiteralPath $archive -Force
}
Compress-Archive -Path (Join-Path $distRoot '*') -DestinationPath $archive

if ($env:GITHUB_OUTPUT) {
  "archive=$archive" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
} else {
  "archive=$archive"
}
