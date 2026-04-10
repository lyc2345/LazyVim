param(
    [string]$BundleRoot = $PSScriptRoot,
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Test-Command {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Copy-Directory {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if (-not (Test-Path $Source)) {
        throw "Source directory not found: $Source"
    }

    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    & robocopy $Source $Destination /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
    $exitCode = $LASTEXITCODE
    if ($exitCode -ge 8) {
        throw "robocopy failed from $Source to $Destination with exit code $exitCode."
    }
}

function Backup-Directory {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Timestamp
    )

    if (-not (Test-Path $Path)) {
        return
    }

    if ($NoBackup) {
        Write-Host "NoBackup set. Existing directory will be overwritten by robocopy: $Path" -ForegroundColor Yellow
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

if (-not (Test-Command "robocopy")) {
    throw "robocopy is required. It should be available on Windows by default."
}

if ($BundleRoot -eq $PSScriptRoot) {
    $candidateRoot = Split-Path -Parent $PSScriptRoot
    if ((Test-Path (Join-Path $candidateRoot "nvim")) -and (Test-Path (Join-Path $candidateRoot "nvim-data"))) {
        $BundleRoot = $candidateRoot
    }
}

$bundleRootFull = (Resolve-Path -LiteralPath $BundleRoot).Path
$sourceConfig = Join-Path $bundleRootFull "nvim"
$sourceData = Join-Path $bundleRootFull "nvim-data"
$targetConfig = Join-Path $localAppData "nvim"
$targetData = Join-Path $localAppData "nvim-data"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

if (-not (Test-Path (Join-Path $sourceConfig "init.lua"))) {
    throw "Bundle config is invalid. Missing: $sourceConfig\init.lua"
}

if (-not (Test-Path $sourceData)) {
    throw "Bundle data directory is invalid. Missing: $sourceData"
}

Write-Step "Installing Neovim offline bundle"
Write-Host "Source: $bundleRootFull"
Write-Host "Config: $targetConfig"
Write-Host "Data:   $targetData"

Backup-Directory -Path $targetConfig -Timestamp $timestamp
Backup-Directory -Path $targetData -Timestamp $timestamp

Write-Step "Copying config"
Copy-Directory -Source $sourceConfig -Destination $targetConfig

Write-Step "Copying data"
Copy-Directory -Source $sourceData -Destination $targetData

$localConfigDir = Join-Path $targetConfig "lua\config"
New-Item -ItemType Directory -Force -Path $localConfigDir | Out-Null
$localConfigPath = Join-Path $localConfigDir "local.lua"
if (-not (Test-Path $localConfigPath)) {
    @"
-- Machine-specific settings for the firewalled Windows machine.

return {
  nvim_updates_disabled = true,
}
"@ | Set-Content -Path $localConfigPath -Encoding UTF8
}

Write-Step "Checking commands"
foreach ($command in @("nvim", "git", "rg", "fd", "node", "npx", "python")) {
    if (Test-Command $command) {
        Write-Host ("[OK]   {0}" -f $command) -ForegroundColor Green
    }
    else {
        Write-Host ("[MISS] {0}" -f $command) -ForegroundColor Yellow
    }
}

Write-Step "Installed"
Write-Host "Open a new terminal, then run: nvim"
Write-Host "If Neovim opens, do not run :Lazy sync on the firewalled machine."
