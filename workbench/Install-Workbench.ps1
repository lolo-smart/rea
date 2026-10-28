param([switch]$ConfigureCodex)
$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$version = (Get-Content -LiteralPath (Join-Path $repositoryRoot 'package.json') -Raw | ConvertFrom-Json).version
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw 'The repository must select a stable REA version.' }
$nodeCommand = (Get-Command node -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
$nodeVersion = [version](& $nodeCommand -p 'process.versions.node')
$supported = ($nodeVersion.Major -eq 22 -and $nodeVersion -ge [version]'22.23.4') -or ($nodeVersion.Major -eq 24 -and $nodeVersion -ge [version]'24.22.1') -or ($nodeVersion -ge [version]'26.12.1')
if (-not $supported) { throw 'Use Node 22.23.4+, 24.22.1+, or 26.12.1+ on the supported release line. This installer does not upgrade Node.' }
$runtimeRoot = Join-Path $repositoryRoot ".local\runtime\$version"
$launcher = Join-Path $runtimeRoot 'node_modules\rea-agents\scripts\rea.mjs'
if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) {
    $npmCommand = (Get-Command npm.cmd -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
    & $npmCommand install --prefix $runtimeRoot "rea-agents@$version" --ignore-scripts --no-audit --no-fund --registry=https://registry.npmjs.org
    if ($LASTEXITCODE -ne 0) { throw 'REA runtime installation failed.' }
}
$installedVersion = (Get-Content -LiteralPath (Join-Path $runtimeRoot 'node_modules\rea-agents\package.json') -Raw | ConvertFrom-Json).version
if ($installedVersion -ne $version) { throw 'The installed runtime does not match package.json.' }
& (Join-Path $PSScriptRoot 'rea.ps1') --version
if ($LASTEXITCODE -ne 0) { throw 'REA startup check failed.' }
if ($ConfigureCodex) {
    & (Join-Path $PSScriptRoot 'rea.ps1') setup --client codex --dry-run --json
    if ($LASTEXITCODE -ne 0) { throw 'Codex setup plan failed.' }
    # The upstream setup UI displays and confirms the concrete configuration changes.
    & (Join-Path $PSScriptRoot 'rea.ps1') setup --client codex
    if ($LASTEXITCODE -ne 0) { throw 'Codex setup was not completed.' }
}
