$ErrorActionPreference = 'Stop'

$lazbuild = if ($env:LAZBUILD) { $env:LAZBUILD } else { 'lazbuild' }
& $lazbuild "tests/opencode_manager_tests.lpi"

if (-not (Test-Path -LiteralPath "lib/tests")) {
  throw 'Test build completed but lib/tests was not created.'
}

$runner = Get-ChildItem -LiteralPath "lib/tests" -Recurse -File |
  Where-Object { $_.Name -eq 'test_runner' -or $_.Name -eq 'test_runner.exe' } |
  Select-Object -First 1

if (-not $runner) {
  throw 'Unable to find compiled test_runner binary under lib/tests.'
}

& $runner.FullName --all --format=plain
