$ErrorActionPreference = 'Stop'

$lazbuild = if ($env:LAZBUILD) { $env:LAZBUILD } else { 'lazbuild' }
& $lazbuild "tests/opencode_manager_tests.lpi"

$runner = Get-ChildItem -LiteralPath "lib/tests" -Recurse -File |
  Where-Object { $_.Name -eq 'test_runner' -or $_.Name -eq 'test_runner.exe' } |
  Select-Object -First 1

if (-not $runner) {
  throw 'Unable to find compiled test_runner binary under lib/tests.'
}

if ($IsWindows) {
  $sqliteRoots = @(
    'C:\ProgramData\chocolatey\lib\sqlite\tools',
    'C:\tools\sqlite',
    'C:\tools\sqlite3'
  ) |
    Where-Object { $_ -and (Test-Path -LiteralPath $_) }
  $sqliteDll = $sqliteRoots |
    ForEach-Object { Get-ChildItem -LiteralPath $_ -Recurse -File -Filter 'sqlite3.dll' -ErrorAction SilentlyContinue } |
    Sort-Object @{ Expression = { if ($_.FullName -match 'x64|win64') { 0 } else { 1 } } }, FullName |
    Select-Object -First 1
  $localSqliteDll = Join-Path $runner.DirectoryName 'sqlite3.dll'
  if ($sqliteDll) {
    Copy-Item -LiteralPath $sqliteDll.FullName -Destination $runner.DirectoryName -Force
  } elseif (Test-Path -LiteralPath $localSqliteDll) {
    Remove-Item -LiteralPath $localSqliteDll -Force
  }
}

$testOutput = & $runner.FullName --all --format=plain 2>&1
$testOutput
if ($LASTEXITCODE -ne 0) {
  throw "test_runner exited with code $LASTEXITCODE"
}
if (($testOutput -match 'Number of errors:\s+[1-9]') -or ($testOutput -match 'Number of failures:\s+[1-9]')) {
  throw 'test_runner reported errors or failures.'
}
