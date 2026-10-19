#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Flutter = 'flutter',
    [ValidateSet('debug', 'release')][string]$Mode = 'release',
    [switch]$SkipTests,
    [switch]$DoctorOnly
)
$ErrorActionPreference = 'Stop'
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'Run this script on Windows; macOS cannot build a Windows executable.'
}
$taskRoot = Split-Path $PSScriptRoot
$taskArtifacts = Join-Path $taskRoot 'artifacts/windows'
$taskRun = Join-Path $taskArtifacts ('runs/' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force $taskRun | Out-Null
$taskSteps = [System.Collections.Generic.List[object]]::new()
$taskStatus = 'failed'
$taskStage = 'environment'
$taskArchive = $null
$taskArchiveHash = $null
$taskTranscript = $false

function Invoke-Checked([string]$Program, [string[]]$Arguments) {
    Write-Host ("> " + [IO.Path]::GetFileName($Program) + ' ' + ($Arguments -join ' '))
    $taskStepLog = ('{0:D2}-{1}.log' -f $taskSteps.Count, [IO.Path]::GetFileName($Program))
    $taskWatch = [Diagnostics.Stopwatch]::StartNew()
    $taskPreviousPreference = $ErrorActionPreference
    try {
        # Windows PowerShell turns redirected native stderr into ErrorRecords.
        # Judge native commands by their exit code, while recording both streams.
        $ErrorActionPreference = 'Continue'
        & $Program @Arguments 2>&1 |
            Tee-Object -FilePath (Join-Path $taskRun $taskStepLog) -ErrorAction Stop |
            Out-Host
        $taskNativeExit = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $taskPreviousPreference
    }
    $taskWatch.Stop()
    $taskSteps.Add([pscustomobject]@{
        program = [IO.Path]::GetFileName($Program)
        arguments = $Arguments
        exitCode = $taskNativeExit
        elapsedMs = $taskWatch.ElapsedMilliseconds
        log = $taskStepLog
    })
    if ($taskNativeExit -ne 0) { throw "$Program $Arguments exited with $taskNativeExit" }
}

Push-Location $taskRoot
try {
    Start-Transcript -Path (Join-Path $taskRun 'build.log') | Out-Null
    $taskTranscript = $true
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    $taskFlutter = (Get-Command $Flutter -ErrorAction Stop).Source
    $taskDart = Join-Path (Split-Path $taskFlutter) 'dart.bat'
    if (!(Test-Path $taskDart -PathType Leaf)) {
        throw 'Dart must be available beside flutter.bat. Pass -Flutter with the SDK flutter.bat path.'
    }
    Get-Command git -ErrorAction Stop | Select-Object Name, Source | Format-Table
    Invoke-Checked $taskFlutter @('--version')
    if ($DoctorOnly) {
        $taskStage = 'doctor'
        Invoke-Checked $taskFlutter @('doctor', '-v')
        $taskStatus = 'doctor-complete'
        return
    }
    if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
        throw 'This packaging script currently requires an x64 Windows host.'
    }
    $taskStage = 'dependencies'
    Invoke-Checked $taskFlutter @('pub', 'get')
    Push-Location 'packages/dukto2_core'
    try { Invoke-Checked $taskDart @('pub', 'get') } finally { Pop-Location }
    if (!$SkipTests) {
        $taskStage = 'checks'
        Invoke-Checked $taskDart @('analyze')
        Invoke-Checked $taskFlutter @('test')
        Push-Location 'packages/dukto2_core'
        try {
            Invoke-Checked $taskDart @('analyze')
            Invoke-Checked $taskDart @('test')
        } finally { Pop-Location }
    }
    $taskStage = 'build'
    # Flutter 3.47 selects Windows architecture from the host; no target-platform flag.
    Invoke-Checked $taskFlutter @('build', 'windows', "--$Mode")
    if ($Mode -eq 'release') {
        $taskStage = 'package'
        $bundle = Join-Path $taskRoot 'build/windows/x64/runner/Release'
        foreach ($taskRequired in @('Dukto2.exe', 'flutter_windows.dll', 'data/icudtl.dat', 'data/flutter_assets')) {
            if (!(Test-Path (Join-Path $bundle $taskRequired))) {
                throw "Incomplete release bundle: missing $taskRequired"
            }
        }
        foreach ($taskLegalFile in @('LICENSE', 'ACKNOWLEDGEMENTS.md', 'THIRD_PARTY_NOTICES.md')) {
            Copy-Item (Join-Path $taskRoot $taskLegalFile) $bundle
        }
        Copy-Item (Join-Path $taskRoot 'licenses') $bundle -Recurse -Force
        Copy-Item (Join-Path $taskRoot 'docs/windows.md') (Join-Path $bundle 'WINDOWS.md')
        $taskArchive = Join-Path $taskArtifacts 'Dukto2-windows-x64-release.zip'
        $taskTemporaryArchive = Join-Path $taskRun 'Dukto2-windows-x64-release.zip'
        Compress-Archive -Path (Join-Path $bundle '*') -DestinationPath $taskTemporaryArchive
        $taskArchiveHash = (Get-FileHash $taskTemporaryArchive -Algorithm SHA256).Hash
        Move-Item -Path $taskTemporaryArchive -Destination $taskArchive -Force
        Write-Host "Package: $taskArchive"
        Write-Host "SHA256: $taskArchiveHash"
    }
    $taskStatus = 'built'
} finally {
    [ordered]@{
        status = $taskStatus
        stage = $taskStage
        mode = $Mode
        testsRequested = !$SkipTests -and !$DoctorOnly
        steps = @($taskSteps.ToArray())
        archive = $taskArchive
        sha256 = $taskArchiveHash
        completedAt = [DateTimeOffset]::Now.ToString('o')
    } | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $taskRun 'result.json') -Encoding UTF8
    if ($taskTranscript) { Stop-Transcript | Out-Null }
    Write-Host "Build record: $taskRun"
    Pop-Location
}
