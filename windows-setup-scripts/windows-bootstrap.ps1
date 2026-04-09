param(
    [string]$ConfigZip,
    [string]$LazyZip,
    [switch]$SetAiEnv
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

function Expand-ArchiveSafe {
    param(
        [Parameter(Mandatory = $true)][string]$ZipPath,
        [Parameter(Mandatory = $true)][string]$DestinationPath
    )

    if (-not (Test-Path $ZipPath)) {
        throw "Zip not found: $ZipPath"
    }

    New-Item -ItemType Directory -Force -Path $DestinationPath | Out-Null
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $DestinationPath -Force
}

function Resolve-LatestZip {
    param(
        [Parameter(Mandatory = $true)][string[]]$SearchRoots,
        [Parameter(Mandatory = $true)][string]$Pattern
    )

    $candidates = @()
    foreach ($root in $SearchRoots) {
        if (Test-Path $root) {
            $candidates += Get-ChildItem -Path $root -Filter $Pattern -File -ErrorAction SilentlyContinue
        }
    }

    return $candidates | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

$localAppData = $env:LOCALAPPDATA
if ([string]::IsNullOrWhiteSpace($localAppData)) {
    throw "LOCALAPPDATA is not set."
}

$nvimConfigDir = Join-Path $localAppData "nvim"
$nvimDataDir = Join-Path $localAppData "nvim-data"
$nvimLazyDir = Join-Path $nvimDataDir "lazy"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$searchRoots = @(
    (Get-Location).Path,
    $scriptDir,
    (Join-Path $scriptDir "..\dist\windows-pack")
)

Write-Step "Preparing directories"
New-Item -ItemType Directory -Force -Path $nvimConfigDir | Out-Null
New-Item -ItemType Directory -Force -Path $nvimLazyDir | Out-Null
Write-Host "Config: $nvimConfigDir"
Write-Host "Lazy:   $nvimLazyDir"

if (-not $ConfigZip) {
    $foundConfigZip = Resolve-LatestZip -SearchRoots $searchRoots -Pattern "nvim-config-*.zip"
    if ($foundConfigZip) {
        $ConfigZip = $foundConfigZip.FullName
    }
}

if ($ConfigZip) {
    Write-Step "Extracting config zip"
    Write-Host "Using: $ConfigZip"
    Expand-ArchiveSafe -ZipPath $ConfigZip -DestinationPath $localAppData
}
else {
    Write-Step "Config zip not provided"
    Write-Host "Pass -ConfigZip path\to\nvim-config-*.zip or place it next to this script."
}

if (-not $LazyZip) {
    $foundLazyZip = Resolve-LatestZip -SearchRoots $searchRoots -Pattern "nvim-lazy-plugins-*.zip"
    if ($foundLazyZip) {
        $LazyZip = $foundLazyZip.FullName
    }
}

if ($LazyZip) {
    Write-Step "Extracting lazy plugin zip"
    Write-Host "Using: $LazyZip"
    Expand-ArchiveSafe -ZipPath $LazyZip -DestinationPath $nvimDataDir
}
else {
    Write-Step "Lazy zip not provided"
    Write-Host "Pass -LazyZip path\to\nvim-lazy-plugins-*.zip or place it next to this script."
}

Write-Step "Checking required commands"
$checks = @(
    @{ Name = "nvim"; Required = $true; Note = "Neovim 0.11+" },
    @{ Name = "git"; Required = $true; Note = "Git" },
    @{ Name = "rg"; Required = $true; Note = "ripgrep" },
    @{ Name = "fd"; Required = $true; Note = "fd" },
    @{ Name = "node"; Required = $true; Note = "Node.js" },
    @{ Name = "npx"; Required = $true; Note = "npx for Avante/Codex" },
    @{ Name = "python"; Required = $true; Note = "Python 3" }
)

$missing = @()
foreach ($check in $checks) {
    if (Test-Command $check.Name) {
        Write-Host ("[OK]   {0} ({1})" -f $check.Name, $check.Note) -ForegroundColor Green
    }
    else {
        Write-Host ("[MISS] {0} ({1})" -f $check.Name, $check.Note) -ForegroundColor Yellow
        $missing += $check.Name
    }
}

Write-Step "Checking optional commands"
$optionalChecks = @(
    @{ Name = "gcc"; Note = "native plugin builds" },
    @{ Name = "clang"; Note = "native plugin builds" }
)

foreach ($check in $optionalChecks) {
    if (Test-Command $check.Name) {
        Write-Host ("[OK]   {0} ({1})" -f $check.Name, $check.Note) -ForegroundColor Green
    }
    else {
        Write-Host ("[SKIP] {0} ({1})" -f $check.Name, $check.Note) -ForegroundColor DarkYellow
    }
}

if ($SetAiEnv) {
    Write-Step "Setting user environment variables for AI"
    if (-not $env:OPENAI_API_KEY) {
        $openAiKey = Read-Host "Enter OPENAI_API_KEY"
        if (-not [string]::IsNullOrWhiteSpace($openAiKey)) {
            [Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $openAiKey, "User")
            [Environment]::SetEnvironmentVariable("AVANTE_OPENAI_API_KEY", $openAiKey, "User")
            Write-Host "Saved OPENAI_API_KEY and AVANTE_OPENAI_API_KEY to User environment." -ForegroundColor Green
        }
    }
    else {
        [Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $env:OPENAI_API_KEY, "User")
        [Environment]::SetEnvironmentVariable("AVANTE_OPENAI_API_KEY", $env:OPENAI_API_KEY, "User")
        Write-Host "Saved current OPENAI_API_KEY to User environment." -ForegroundColor Green
    }

    if (-not $env:AVANTE_ANTHROPIC_API_KEY) {
        $anthropicKey = Read-Host "Enter AVANTE_ANTHROPIC_API_KEY (leave blank to skip)"
        if (-not [string]::IsNullOrWhiteSpace($anthropicKey)) {
            [Environment]::SetEnvironmentVariable("AVANTE_ANTHROPIC_API_KEY", $anthropicKey, "User")
            Write-Host "Saved AVANTE_ANTHROPIC_API_KEY to User environment." -ForegroundColor Green
        }
    }
    else {
        [Environment]::SetEnvironmentVariable("AVANTE_ANTHROPIC_API_KEY", $env:AVANTE_ANTHROPIC_API_KEY, "User")
        Write-Host "Saved current AVANTE_ANTHROPIC_API_KEY to User environment." -ForegroundColor Green
    }
}

Write-Step "Notes"
Write-Host "- Do not copy macOS Mason packages directly to Windows."
Write-Host "- Do not copy macOS Treesitter parsers directly to Windows."
Write-Host "- Some plugins may still need Windows-native builds later."

Write-Step "Verifying extracted files"
$verifyFailures = @()

$initLua = Join-Path $nvimConfigDir "init.lua"
if (Test-Path $initLua) {
    Write-Host "[OK]   Found init.lua" -ForegroundColor Green
}
else {
    Write-Host "[MISS] init.lua not found in $nvimConfigDir" -ForegroundColor Yellow
    $verifyFailures += "config"
}

$luaPluginsDir = Join-Path $nvimConfigDir "lua\plugins"
if (Test-Path $luaPluginsDir) {
    Write-Host "[OK]   Found lua\\plugins" -ForegroundColor Green
}
else {
    Write-Host "[MISS] lua\\plugins not found in $nvimConfigDir" -ForegroundColor Yellow
    $verifyFailures += "config-layout"
}

$lazyvimDir = Join-Path $nvimLazyDir "LazyVim"
if (Test-Path $lazyvimDir) {
    Write-Host "[OK]   Found LazyVim checkout" -ForegroundColor Green
}
else {
    Write-Host "[MISS] LazyVim checkout not found in $nvimLazyDir" -ForegroundColor Yellow
    $verifyFailures += "lazy"
}

$snacksDir = Join-Path $nvimLazyDir "snacks.nvim"
if (Test-Path $snacksDir) {
    Write-Host "[OK]   Found snacks.nvim checkout" -ForegroundColor Green
}
else {
    Write-Host "[MISS] snacks.nvim checkout not found in $nvimLazyDir" -ForegroundColor Yellow
    $verifyFailures += "lazy-plugin"
}

if (Test-Command "nvim") {
    $nvimVersion = & nvim --version 2>$null | Select-Object -First 1
    if ($nvimVersion) {
        Write-Host "[OK]   $nvimVersion" -ForegroundColor Green
    }
}

Write-Step "Next commands"
Write-Host "1. Open a new PowerShell window if you changed environment variables."
Write-Host "2. Run: nvim"
Write-Host "3. In Neovim, check: <Space>, <leader><space>, <leader>fp"
Write-Host "4. When network or internal mirrors are available, run: :Lazy sync, :Mason, :TSUpdate"

if ($missing.Count -gt 0) {
    Write-Step "Missing required commands"
    Write-Host ("Missing: {0}" -f ($missing -join ", ")) -ForegroundColor Yellow
    exit 1
}

if ($verifyFailures.Count -gt 0) {
    Write-Step "Verification warnings"
    Write-Host ("Check these areas: {0}" -f ($verifyFailures -join ", ")) -ForegroundColor Yellow
    exit 1
}

Write-Step "Bootstrap completed"
