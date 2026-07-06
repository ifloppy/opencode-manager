$ErrorActionPreference = 'Stop'

if (Test-Path -LiteralPath "lib") { Remove-Item -LiteralPath "lib" -Recurse -Force }
Get-ChildItem -Path . -Recurse -Include *.o,*.ppu,*.compiled,*.bak,*.exe | Remove-Item -Force
