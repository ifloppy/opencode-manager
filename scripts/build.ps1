$ErrorActionPreference = 'Stop'

$lazbuild = if ($env:LAZBUILD) { $env:LAZBUILD } else { 'lazbuild' }
& $lazbuild "src/app/opencode_manager.lpi"
