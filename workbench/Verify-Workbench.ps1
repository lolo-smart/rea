param([string]$MetadataPath, [string]$BinaryPath)
$ErrorActionPreference = 'Stop'
if ($BinaryPath -and -not $MetadataPath) { throw 'BinaryPath requires MetadataPath.' }
$reaCommand = Join-Path $PSScriptRoot 'rea.ps1'
& $reaCommand mcp doctor --json
if ($LASTEXITCODE -ne 0) { throw 'Production MCP self-check failed.' }
if ($MetadataPath) {
    $metadata = (Resolve-Path -LiteralPath $MetadataPath -ErrorAction Stop).Path
    if (-not (Test-Path -LiteralPath $metadata -PathType Leaf)) { throw 'MetadataPath must name a regular file.' }
    $repositoryRoot = Split-Path -Parent $PSScriptRoot
    $output = Join-Path $repositoryRoot ('.local\verification\' + [DateTimeOffset]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $output -ErrorAction Stop | Out-Null
    $request = @('inspect-il2cpp-metadata', $metadata, '--detail', 'summary', '--evidence_output', (Join-Path $output 'il2cpp.evidence.json'), '--json')
    if ($BinaryPath) {
        $binary = (Resolve-Path -LiteralPath $BinaryPath -ErrorAction Stop).Path
        if (-not (Test-Path -LiteralPath $binary -PathType Leaf)) { throw 'BinaryPath must name a regular file.' }
        $request += @('--binary', $binary)
    }
    & $reaCommand @request | Set-Content -LiteralPath (Join-Path $output 'summary.json') -Encoding utf8
    if ($LASTEXITCODE -ne 0) { throw "IL2CPP inspection failed. Local diagnostics: $output" }
    Write-Output "Local inspection results: $output"
}
