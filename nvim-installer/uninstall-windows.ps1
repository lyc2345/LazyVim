param(
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Backup-Directory {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Timestamp
    )

    if (-not (Test-Path $Path)) {
        Write-Host "Skip missing directory: $Path" -ForegroundColor DarkGray
        return
    }

    if ($NoBackup) {
        Write-Host "Removing without backup: $Path" -ForegroundColor Yellow
        Remove-Item -LiteralPath $Path -Recurse -Force
        return
    }

    $backupPath = "$Path.backup.$Timestamp"
    Write-Host "Backing up $Path to $backupPath"
    Move-Item -LiteralPath $Path -Destination $backupPath
}

$localAppData = $env:LOCALAPPDATA
if ([string]::IsNullOrWhiteSpace($localAppData)) {
    throw "LOCALAPPDATA is not set."
}

$targetConfig = Join-Path $localAppData "nvim"
$targetData = Join-Path $localAppData "nvim-data"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Step "Uninstalling Neovim offline bundle"
Backup-Directory -Path $targetConfig -Timestamp $timestamp
Backup-Directory -Path $targetData -Timestamp $timestamp

Write-Step "Uninstalled"
if ($NoBackup) {
    Write-Host "Removed $targetConfig and $targetData."
}
else {
    Write-Host "Existing directories were renamed with .backup.$timestamp suffix."
}
