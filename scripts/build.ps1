$ErrorActionPreference = 'Stop'

$lazbuild = if ($env:LAZBUILD) { $env:LAZBUILD } else { 'lazbuild' }
& "$PSScriptRoot\register-packages.ps1"
& $lazbuild "src/app/opencode_manager.lpi"
