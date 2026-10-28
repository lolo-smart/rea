$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$version = (Get-Content -LiteralPath (Join-Path $repositoryRoot 'package.json') -Raw | ConvertFrom-Json).version
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw 'The repository must select a stable REA version.' }
$launcher = Join-Path $repositoryRoot ".local\runtime\$version\node_modules\rea-agents\scripts\rea.mjs"
if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) { throw 'Run workbench\Install-Workbench.ps1 first.' }
$nodeCommand = (Get-Command node -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
$settingsPath = Join-Path $repositoryRoot '.local\providers.json'
$previousValues = @{}
$result = 1
try {
    if (Test-Path -LiteralPath $settingsPath -PathType Leaf) {
        $settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
        foreach ($property in $settings.PSObject.Properties) {
            if ($property.Name -notmatch '^(REA_[A-Z0-9_]+|JAVA_HOME|GHIDRA_INSTALL_DIR|HOPPER_LAUNCHER_PATH)$') { throw "Unsupported provider setting: $($property.Name)" }
            if ($property.Value -isnot [string] -or $property.Value.Contains([char]0)) { throw "Provider setting must be a string: $($property.Name)" }
            $previousValues[$property.Name] = [Environment]::GetEnvironmentVariable($property.Name, 'Process')
            [Environment]::SetEnvironmentVariable($property.Name, $property.Value, 'Process')
        }
    }
    & $nodeCommand $launcher @args
    $result = $LASTEXITCODE
} finally {
    foreach ($name in $previousValues.Keys) { [Environment]::SetEnvironmentVariable($name, $previousValues[$name], 'Process') }
}
exit $result
