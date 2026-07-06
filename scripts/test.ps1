$ErrorActionPreference = 'Stop'

lazbuild "tests/opencode_manager_tests.lpi"
& ".\lib\tests\x86_64-win64\test_runner.exe" --all --format=plain
