# Windows Setup Checklist

This checklist is for moving this Neovim config to Windows when GitHub access is restricted.

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

If you used [`pack-nvim-for-windows.sh`](/Users/stan/.dotfile/.config/nvim/windows-setup-scripts/pack-nvim-for-windows.sh), you should have:

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

Even if plugin source code was copied successfully, these parts may still need Windows-native installation:

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

If the Windows machine cannot reach GitHub or npm at all, start with this order:

1. Use the copied config and lazy plugin cache.
2. Verify editing, Telescope, which-key, and basic UI work.
3. Disable AI, DAP, or any plugin that still tries to fetch dependencies.
4. Re-enable those features later when you have network access or an internal mirror.

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
