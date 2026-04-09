-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- display
opt.number = true
opt.relativenumber = true
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- split windows
opt.splitright = true
opt.splitbelow = true

-- editing behavior
opt.swapfile = false
opt.autowrite = true
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2

-- Sync clipboard between OS and Neovim.
-- Schedule this to avoid adding startup cost too early.
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- LazyVim auto format
vim.g.autoformat = true

-- Snacks animations
-- Set to `false` to globally disable all snacks animations.
vim.g.snacks_animate = true

-- LazyVim picker to use.
-- Can be one of: telescope, fzf
-- Leave it to "auto" to automatically use the picker.
vim.g.lazyvim_picker = "telescope"

-- LazyVim completion engine to use.
-- Can be one of: nvim-cmp, blink.cmp
-- Leave it to "auto" to automatically use the completion engine.
vim.g.lazyvim_cmp = "auto"

-- If the completion engine supports the AI source,
-- use that instead of inline suggestions.
vim.g.ai_cmp = true

-- LazyVim root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Set LSP servers to be ignored when used for root detection.
vim.g.root_lsp_ignore = { "copilot" }

-- Hide deprecation warnings
vim.g.deprecation_warnings = false

-- Show the current document symbols location from Trouble in lualine.
-- You can disable this per buffer with `vim.b.trouble_lualine = false`.
vim.g.trouble_lualine = true
