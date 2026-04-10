# Windows Setup Checklist

This checklist is for moving this Neovim config to Windows when GitHub access is restricted.

There are two supported workflows:

- Preferred: build and pack on a Windows machine with internet, then move one offline bundle to the firewalled Windows machine.
- Fallback: pack config and lazy plugin source from macOS, then rebuild Windows-native parts later.

## 1. Install prerequisites

Install these first on Windows:

- Neovim 0.11+
- Git
- `ripgrep` (`rg`)
- `fd`
- Node.js + `npm` / `npx`
- Python 3
- A Nerd Font

Recommended:

- WezTerm or Windows Terminal
- `gcc` / `clang` / Visual Studio Build Tools for plugins with native builds

## 2. Copy the packaged files

PowerShell does not automatically run scripts from the current directory. Use `.\script.ps1`, or call PowerShell with `-File`.

### Preferred: Windows-to-Windows offline bundle

On a Windows machine that has GitHub/npm/package access:

1. Put this config at `%LOCALAPPDATA%\nvim`.
2. Open PowerShell.
3. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd "$env:LOCALAPPDATA\nvim\nvim-installer"
.\pack-windows.ps1
```

The script will:

- run `nvim --headless "+Lazy! sync" "+qa"`
- try to install Mason tools
- try to install Treesitter parsers
- copy `%LOCALAPPDATA%\nvim`
- copy `%LOCALAPPDATA%\nvim-data`
- generate `lua\config\local.lua` with `nvim_updates_disabled = true`
- exclude common secret files such as `.env`, private keys, token files, and the original `lua\config\local.lua`
- scan the staged bundle for common API key/token/private-key patterns before compressing
- create `nvim-windows-offline-*.zip`

Copy `nvim-windows-offline-*.zip` to the firewalled Windows machine, extract it, then run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\nvim-installer\install-offline-windows.ps1
```

This copies:

- `nvim` -> `%LOCALAPPDATA%\nvim`
- `nvim-data` -> `%LOCALAPPDATA%\nvim-data`

To uninstall this offline bundle later:

```powershell
.\nvim-installer\uninstall-windows.ps1
```

This is the only workflow that can safely include Windows-native Mason packages, Treesitter parsers, and plugin build artifacts.

Before uploading a generated zip to GitHub Releases, verify it does not contain private data:

```powershell
Expand-Archive .\windows-offline-pack\nvim-windows-offline-*.zip .\inspect-nvim-bundle
Get-ChildItem .\inspect-nvim-bundle -Recurse -Force |
  Where-Object { $_.Name -match '(\.env|credential|secret|token|id_rsa|id_ed25519|\.pem|\.key)$' }
```

If `pack-windows.ps1` reports possible secrets, do not upload the asset. Remove the secret from the source location or confirm it is a false positive before rerunning with `-AllowSecretFindings`.

### Fallback: macOS config and lazy source only

If you used [`pack-nvim-for-windows.sh`](/Users/stan/.dotfile/nvim/nvim-installer/pack-nvim-for-windows.sh), you should have:

- `nvim-config-*.zip`
- `nvim-lazy-plugins-*.zip`

Extract them to:

- `nvim-config-*.zip` -> `%LOCALAPPDATA%\nvim`
- `nvim-lazy-plugins-*.zip` -> `%LOCALAPPDATA%\nvim-data\lazy`

Do not copy these macOS-specific paths directly:

- `~/.local/share/nvim/mason`
- `~/.local/share/nvim/site/parser`
- anything ending in `.so` or `.dylib`

## 3. First launch

Open Windows PowerShell or your terminal, then run:

```powershell
nvim
```

On first launch, check:

- colorscheme loads
- Telescope opens with `<leader><space>`
- Which-key opens with `<Space>`
- Explorer opens and can open files

## 4. Rebuild or reinstall platform-specific parts

If you used the Windows-to-Windows offline bundle, these parts should already be staged from the online Windows machine.

If you used the macOS fallback package, these parts may still need Windows-native installation:

- Mason tools
- Treesitter parsers
- plugins with native binaries

Run these when network or package mirrors are available:

```vim
:Lazy sync
:Mason
:TSUpdate
```

## 5. Features that may fail offline

These parts of the current config may not work immediately on Windows without network access:

- `Avante` with `codex`
  - uses `npx @zed-industries/codex-acp`
  - first run may try to download packages
- `Avante` with `claude`
  - still needs API access
- Python DAP
  - needs Windows `debugpy`
- Mason-managed LSP servers / formatters / linters

## 6. Environment variables for AI

Set these in your Windows shell profile if you want AI features:

```powershell
$env:OPENAI_API_KEY="your-openai-api-key"
$env:AVANTE_OPENAI_API_KEY=$env:OPENAI_API_KEY
$env:AVANTE_ANTHROPIC_API_KEY="your-anthropic-api-key"
```

If you want them to persist, add them to your PowerShell profile instead of typing them every time.

## 7. Recommended fallback if Windows is fully offline

If the Windows machine cannot reach GitHub or npm at all, use this order:

1. Prefer `pack-windows.ps1` on another Windows machine with network access.
2. Move the generated `nvim-windows-offline-*.zip`.
3. Install it with `install-offline-windows.ps1`.
4. Use the copied config, lazy plugin cache, Mason tools, Treesitter parsers, and native builds.
5. Disable plugin update checks with `:NvimUpdatesDisable` if needed.
6. Verify editing, Telescope, which-key, and basic UI work.
7. Disable AI, DAP, or any plugin that still tries to fetch dependencies.
8. Re-enable those features later when you have network access or an internal mirror.

If you only have the macOS fallback package:

1. Use the copied config and lazy plugin cache.
2. Disable plugin update checks with `:NvimUpdatesDisable`.
3. Verify editing, Telescope, which-key, and basic UI work.
4. Disable AI, DAP, or any plugin that still tries to fetch dependencies.
5. Re-enable those features later when you have network access or an internal mirror.

The current update-check flag is available inside Neovim as:

```lua
vim.g.nvim_updates_disabled
```

The single persistent config source is:

```lua
-- %LOCALAPPDATA%\nvim\lua\config\local.lua
return {
  nvim_updates_disabled = true,
}
```

## 8. Likely first things to verify in this config

These are the most useful smoke tests for this setup:

1. `<Space>` shows which-key
2. `<leader><space>` opens Telescope file search
3. `<leader>fp` opens projects
4. Explorer can stay open and open files without errors
5. `<leader>ac` opens AI chat
6. `<leader>db` sets a breakpoint in a Python file

## 9. If something breaks on Windows

Start with:

```vim
:messages
:checkhealth
:Lazy
:Mason
```

Common causes:

- missing `rg` or `fd`
- missing Windows-native parser / binary
- missing Node.js
- missing Python
- missing API keys
- first-run build step blocked by network policy

## 10. Before uploading to GitHub Releases

Do not upload a bundle until these checks pass:

1. Secrets are only stored in environment variables or machine-local files.
2. `%LOCALAPPDATA%\nvim\lua\config\local.lua` does not contain API keys. The pack script replaces this file in the staged bundle.
3. No `.env`, private key, token, or credentials files are present in the extracted zip.
4. `pack-windows.ps1` completes its secret scan without warnings.
5. If a real key was uploaded by mistake, revoke and rotate that key. Deleting the asset is not enough.

Good places for private values:

- Windows user environment variables
- Windows Credential Manager
- a private machine-only `lua\config\local.lua` that is never committed or published

Bad places for private values:

- committed Lua files
- Release assets
- zip bundles intended for other machines
- plugin cache/state folders that may contain chat history or tokens
