param(
    [Parameter(Mandatory)][string]$Installer,
    [Parameter(Mandatory)][string]$Bundle,
    [Parameter(Mandatory)][string]$Report
)
$ErrorActionPreference = 'Stop'
$testRoot = Join-Path $env:RUNNER_TEMP ('dukto2-installer-' + [guid]::NewGuid().ToString('N'))
$installDir = Join-Path $testRoot 'program'
New-Item -ItemType Directory -Force $testRoot | Out-Null

function Install-TestBundle {
    $process = Start-Process -FilePath $Installer -ArgumentList @(
        '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-',
        ('/DIR="' + $installDir + '"'), ('/LOG="' + (Join-Path $testRoot 'install.log') + '"')
    ) -PassThru -Wait
    if ($process.ExitCode -ne 0) { throw "Installer failed: $($process.ExitCode)" }
}

Install-TestBundle
$files = @(Get-ChildItem $Bundle -Recurse -File)
foreach ($source in $files) {
    $relative = [IO.Path]::GetRelativePath($Bundle, $source.FullName)
    $installed = Join-Path $installDir $relative
    if (!(Test-Path $installed -PathType Leaf)) { throw "Missing installed payload: $relative" }
    if ((Get-FileHash $source.FullName -Algorithm SHA256).Hash -ne (Get-FileHash $installed -Algorithm SHA256).Hash) {
        throw "Installed payload mismatch: $relative"
    }
}
$uninstaller = Join-Path $installDir 'unins000.exe'
if (!(Test-Path $uninstaller -PathType Leaf)) { throw 'Uninstaller missing' }
# The same installer must update the same directory without another app copy.
Install-TestBundle
$uninstall = Start-Process $uninstaller -ArgumentList @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART') -PassThru -Wait
if ($uninstall.ExitCode -ne 0) { throw "Uninstaller failed: $($uninstall.ExitCode)" }
if (Test-Path (Join-Path $installDir 'Dukto2.exe')) { throw 'Uninstall did not remove the installed application' }
[ordered]@{
    status = 'passed'
    checks = @('silent install', 'all payload files SHA-256 matched', 'same-version reinstall', 'silent uninstall')
    payloadFiles = $files.Count
    validationLimit = 'CI install/reinstall/uninstall only; not Windows GUI or LAN acceptance'
} | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 $Report
