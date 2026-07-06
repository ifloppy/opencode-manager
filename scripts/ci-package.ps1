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
    'C:\lazarus',
    'C:\tools',
    $env:ChocolateyInstall
  ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
  $sqliteDll = $sqliteSearchRoots |
    ForEach-Object { Get-ChildItem -LiteralPath $_ -Recurse -Filter 'sqlite3.dll' -ErrorAction SilentlyContinue } |
    Where-Object { $_.FullName -match 'lazarus|fpc|sqlite' } |
    Select-Object -First 1
  if ($sqliteDll) {
    Copy-Item -LiteralPath $sqliteDll.FullName -Destination $distRoot
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
