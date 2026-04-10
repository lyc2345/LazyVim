param(
    [string]$OutDir = (Join-Path (Get-Location) "windows-offline-pack"),
    [switch]$SkipLazySync,
    [switch]$SkipMason,
    [switch]$SkipTreesitter,
    [switch]$IncludeState,
    [switch]$ContinueOnNvimError,
    [switch]$AllowSecretFindings
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

function Invoke-NvimHeadless {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowFailure
    )

    Write-Step $Label
    Write-Host ("nvim --headless {0}" -f ($Arguments -join " "))
    & nvim --headless @Arguments
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        $message = "$Label failed with exit code $exitCode."
        if ($AllowFailure -or $ContinueOnNvimError) {
            Write-Host "[WARN] $message" -ForegroundColor Yellow
            return
        }

        throw $message
    }
}

function Invoke-NvimLua {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Lua,
        [switch]$AllowFailure
    )

    $safeLabel = $Label -replace "[^A-Za-z0-9_-]", "-"
    $luaPath = Join-Path $env:TEMP "nvim-pack-$safeLabel-$PID.lua"
    Set-Content -Path $luaPath -Value $Lua -Encoding UTF8

    try {
        Invoke-NvimHeadless -Label $Label -Arguments @("+luafile $luaPath", "+qa") -AllowFailure:$AllowFailure
    }
    finally {
        if (Test-Path $luaPath) {
            Remove-Item -Force $luaPath
        }
    }
}

function Copy-Directory {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination,
        [string[]]$ExcludeDirs = @(),
        [string[]]$ExcludeFiles = @()
    )

    if (-not (Test-Path $Source)) {
        throw "Source directory not found: $Source"
    }

    New-Item -ItemType Directory -Force -Path $Destination | Out-Null

    $robocopyArgs = @(
        $Source,
        $Destination,
        "/MIR",
        "/NFL",
        "/NDL",
        "/NJH",
        "/NJS",
        "/NP"
    )

    if ($ExcludeDirs.Count -gt 0) {
        $robocopyArgs += "/XD"
        $robocopyArgs += $ExcludeDirs
    }

    if ($ExcludeFiles.Count -gt 0) {
        $robocopyArgs += "/XF"
        $robocopyArgs += $ExcludeFiles
    }

    & robocopy @robocopyArgs | Out-Null
    $exitCode = $LASTEXITCODE
    if ($exitCode -ge 8) {
        throw "robocopy failed from $Source to $Destination with exit code $exitCode."
    }
}

function Get-SensitiveFilePatterns {
    return @(
        ".env",
        ".env.*",
        "*.pem",
        "*.key",
        "*.p12",
        "*.pfx",
        "id_rsa*",
        "id_ed25519*",
        "known_hosts",
        "authorized_keys",
        ".tokens",
        "credentials.json",
        "credentials.lua",
        "secret.json",
        "secret.lua",
        "secrets.json",
        "secrets.lua",
        "token.json",
        "tokens.json"
    )
}

function Test-SkippedSecretScanFile {
    param([Parameter(Mandatory = $true)]$File)

    $binaryExtensions = @(
        ".7z",
        ".bin",
        ".dll",
        ".dylib",
        ".exe",
        ".gif",
        ".gz",
        ".ico",
        ".jpg",
        ".jpeg",
        ".lockb",
        ".png",
        ".pyd",
        ".so",
        ".tar",
        ".wasm",
        ".zip"
    )

    if ($File.Length -gt 2MB) {
        return $true
    }

    return $binaryExtensions -contains $File.Extension.ToLowerInvariant()
}

function Test-SecretFree {
    param([Parameter(Mandatory = $true)][string]$BundleRoot)

    Write-Step "Scanning staged bundle for common secrets"

    $scanRoots = @(
        (Join-Path $BundleRoot "nvim"),
        (Join-Path $BundleRoot "nvim-data")
    )

    $skipPathPatterns = @(
        "\nvim-data\lazy\",
        "\nvim-data\mason\packages\",
        "\nvim-data\mason\staging\"
    )

    $secretPatterns = @(
        @{ Name = "Anthropic API key"; Pattern = "sk-ant-[A-Za-z0-9_-]{20,}" },
        @{ Name = "OpenAI API key"; Pattern = "sk-(?!ant-)[A-Za-z0-9_-]{20,}" },
        @{ Name = "GitHub token"; Pattern = "(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{20,}" },
        @{ Name = "GitHub fine-grained token"; Pattern = "github_pat_[A-Za-z0-9_]{20,}" },
        @{ Name = "AWS access key"; Pattern = "AKIA[0-9A-Z]{16}" },
        @{ Name = "Private key"; Pattern = "-----BEGIN [A-Z ]*PRIVATE KEY-----" }
    )

    $findings = @()
    foreach ($root in $scanRoots) {
        if (-not (Test-Path $root)) {
            continue
        }

        Get-ChildItem -LiteralPath $root -Recurse -File -Force | ForEach-Object {
            $file = $_
            $normalizedPath = $file.FullName.Replace("/", "\")

            foreach ($skipPattern in $skipPathPatterns) {
                if ($normalizedPath.Contains($skipPattern)) {
                    return
                }
            }

            if (Test-SkippedSecretScanFile -File $file) {
                return
            }

            $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
            if ($null -eq $content) {
                return
            }

            foreach ($secretPattern in $secretPatterns) {
                if ([regex]::IsMatch($content, $secretPattern.Pattern)) {
                    $findings += [PSCustomObject]@{
                        Type = $secretPattern.Name
                        Path = $file.FullName.Substring($BundleRoot.Length + 1)
                    }
                }
            }
        }
    }

    if ($findings.Count -eq 0) {
        Write-Host "[OK]   No common secret patterns found." -ForegroundColor Green
        return
    }

    Write-Host "[WARN] Possible secrets found:" -ForegroundColor Yellow
    foreach ($finding in $findings) {
        Write-Host ("- {0}: {1}" -f $finding.Type, $finding.Path) -ForegroundColor Yellow
    }

    if (-not $AllowSecretFindings) {
        throw "Secret scan failed. Remove the secret or rerun with -AllowSecretFindings if this is a false positive."
    }
}

function Write-OfflineInstallReadme {
    param([Parameter(Mandatory = $true)][string]$Path)

    @"
# Neovim Windows Offline Bundle

This bundle was created on a Windows machine with network access.

## Install on the firewalled Windows machine

1. Extract this zip.
2. Open PowerShell in the extracted folder.
3. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\nvim-installer\install-offline-windows.ps1
```

The installer copies:

- `nvim` to `%LOCALAPPDATA%\nvim`
- `nvim-data` to `%LOCALAPPDATA%\nvim-data`

To uninstall this bundle later:

```powershell
.\nvim-installer\uninstall-windows.ps1
```

## Notes

- This is Windows-to-Windows only. Do not use a macOS-built `nvim-data` folder on Windows.
- The staged config includes `lua\config\local.lua` with `nvim_updates_disabled = true`.
- Do not run `:Lazy sync`, `:Mason`, or `:TSUpdate` on the firewalled machine unless it has access to GitHub/npm/package mirrors.
- If something fails, start with `:messages`, `:checkhealth`, `:Lazy`, and `:Mason`.
"@ | Set-Content -Path $Path -Encoding UTF8
}

$localAppData = $env:LOCALAPPDATA
if ([string]::IsNullOrWhiteSpace($localAppData)) {
    throw "LOCALAPPDATA is not set."
}

if (-not (Test-Command "nvim")) {
    throw "nvim is required. Install Neovim 0.11+ first."
}

if (-not (Test-Command "robocopy")) {
    throw "robocopy is required. It should be available on Windows by default."
}

$nvimConfigDir = Join-Path $localAppData "nvim"
$nvimDataDir = Join-Path $localAppData "nvim-data"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Test-Path (Join-Path $nvimConfigDir "init.lua"))) {
    throw "Neovim config not found at $nvimConfigDir. Install/copy this config there before packing."
}

if (-not $SkipLazySync) {
    Invoke-NvimHeadless -Label "Installing and building lazy.nvim plugins" -Arguments @("+Lazy! sync", "+qa")
}

if (-not $SkipMason) {
    $masonLua = @"
local function warn(message)
  vim.notify(message, vim.log.levels.WARN)
end

local ok_lazy, lazy = pcall(require, "lazy")
if ok_lazy then
  pcall(lazy.load, {
    plugins = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "mason-nvim-dap.nvim",
      "nvim-lspconfig",
    },
  })
end

local ok_registry, registry = pcall(require, "mason-registry")
if not ok_registry then
  warn("mason-registry is unavailable. Open :Mason manually if needed.")
  return
end

local done_refreshing = false
local pending = 0

local function is_installing(pkg)
  return pkg.is_installing and pkg:is_installing() or false
end

local function track_install(pkg)
  if pkg:is_installed() then
    return
  end

  pending = pending + 1
  local finished = false
  local function complete()
    if finished then
      return
    end
    finished = true
    pending = pending - 1
  end

  pkg:once("install:success", complete)
  pkg:once("install:failed", complete)

  if not is_installing(pkg) then
    pkg:install()
  end
end

registry.refresh(function()
  local tools = {}
  if _G.LazyVim and LazyVim.opts then
    local opts = LazyVim.opts("mason.nvim")
    tools = opts.ensure_installed or {}
  end

  for _, tool in ipairs(tools) do
    local ok_package, pkg = pcall(registry.get_package, tool)
    if ok_package then
      track_install(pkg)
    else
      warn("Mason package not found: " .. tool)
    end
  end

  done_refreshing = true
end)

local function any_installing()
  for _, pkg in ipairs(registry.get_all_packages()) do
    if is_installing(pkg) then
      return true
    end
  end
  return false
end

local ok = vim.wait(600000, function()
  return done_refreshing and pending == 0 and not any_installing()
end, 1000)

if not ok then
  error("Timed out waiting for Mason installs.")
end
"@
    Invoke-NvimLua -Label "Installing Mason tools" -Lua $masonLua -AllowFailure
}

if (-not $SkipTreesitter) {
    $treesitterLua = @"
local ok_lazy, lazy = pcall(require, "lazy")
if ok_lazy then
  pcall(lazy.load, { plugins = { "nvim-treesitter" } })
end

local commands = vim.api.nvim_get_commands({})
if commands.TSUpdateSync then
  vim.cmd("TSUpdateSync")
elseif commands.TSUpdate then
  vim.cmd("TSUpdate")
else
  vim.notify("No Treesitter update command found.", vim.log.levels.WARN)
end
"@
    Invoke-NvimLua -Label "Installing Treesitter parsers" -Lua $treesitterLua -AllowFailure
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$outDirFull = (Resolve-Path -LiteralPath $OutDir).Path
$stagingRoot = Join-Path $env:TEMP "nvim-windows-offline-$timestamp"
$bundleRoot = Join-Path $stagingRoot "nvim-windows-offline"
$zipPath = Join-Path $outDirFull "nvim-windows-offline-$timestamp.zip"

Write-Step "Creating staging directory"
if (Test-Path $stagingRoot) {
    Remove-Item -Recurse -Force $stagingRoot
}
New-Item -ItemType Directory -Force -Path $bundleRoot | Out-Null

Write-Step "Copying Neovim config"
$configExcludeDirs = @(
    ".git"
)
$configExcludeFiles = (Get-SensitiveFilePatterns) + @(
    "local.lua"
)
Copy-Directory -Source $nvimConfigDir -Destination (Join-Path $bundleRoot "nvim") -ExcludeDirs $configExcludeDirs -ExcludeFiles $configExcludeFiles

$localConfigDir = Join-Path $bundleRoot "nvim\lua\config"
New-Item -ItemType Directory -Force -Path $localConfigDir | Out-Null
@"
-- Machine-specific settings for the firewalled Windows machine.
-- This file is generated by pack-windows.ps1.

return {
  nvim_updates_disabled = true,
}
"@ | Set-Content -Path (Join-Path $localConfigDir "local.lua") -Encoding UTF8

Write-Step "Copying Neovim data"
$excludeDirs = @(
    (Join-Path $nvimDataDir "avante"),
    (Join-Path $nvimDataDir "codecompanion"),
    (Join-Path $nvimDataDir "copilot-chat"),
    (Join-Path $nvimDataDir "gp.nvim")
)
$excludeFiles = Get-SensitiveFilePatterns
if (-not $IncludeState) {
    $excludeDirs += @("backup", "sessions", "shada", "swap", "undo", "view")
    $excludeFiles += @("*.log", "*.tmp")
}
Copy-Directory -Source $nvimDataDir -Destination (Join-Path $bundleRoot "nvim-data") -ExcludeDirs $excludeDirs -ExcludeFiles $excludeFiles

Write-Step "Copying setup scripts"
$bundleScriptsDir = Join-Path $bundleRoot "nvim-installer"
New-Item -ItemType Directory -Force -Path $bundleScriptsDir | Out-Null
Copy-Item -LiteralPath (Join-Path $scriptDir "install-offline-windows.ps1") -Destination $bundleScriptsDir -Force
Copy-Item -LiteralPath (Join-Path $scriptDir "uninstall-windows.ps1") -Destination $bundleScriptsDir -Force
Copy-Item -LiteralPath (Join-Path $scriptDir "WINDOWS-SETUP.md") -Destination $bundleScriptsDir -Force
Write-OfflineInstallReadme -Path (Join-Path $bundleRoot "INSTALL-OFFLINE.md")

Test-SecretFree -BundleRoot $bundleRoot

Write-Step "Compressing offline bundle"
if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}
Compress-Archive -Path (Join-Path $bundleRoot "*") -DestinationPath $zipPath -CompressionLevel Optimal

Write-Step "Created bundle"
Write-Host $zipPath -ForegroundColor Green
Write-Host ""
Write-Host "Copy this zip to the firewalled Windows machine, extract it, then run:"
Write-Host "  .\nvim-installer\install-offline-windows.ps1"
