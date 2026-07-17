$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$packages = @(
  (Join-Path $root 'packages\fpc_jsonc\src\fpc_jsonc.pas'),
  (Join-Path $root 'packages\fpc_llm_api\src\fpc_llm_api.pas'),
  (Join-Path $root 'packages\fpc_jsonc\fpc_jsonc.lpk'),
  (Join-Path $root 'packages\fpc_llm_api\fpc_llm_api.lpk')
)

foreach ($pkg in $packages) {
  if (-not (Test-Path -LiteralPath $pkg)) {
    throw "Missing package file: $pkg"
  }
}

Write-Host 'Local packages present: fpc_jsonc, fpc_llm_api'
