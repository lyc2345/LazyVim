local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local plugin_updates = require("config.plugin_updates")

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  if not plugin_updates.enabled() then
    vim.api.nvim_echo({
      { "lazy.nvim is missing and plugin updates are disabled.\n", "ErrorMsg" },
      { "Copy your plugin cache to this machine or set `nvim_updates_disabled = false` in `lua/config/local.lua`.\n", "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before loading lazy.nvim
-- so that mappings are registered with the correct prefixes.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local extras = require("config.extras")

require("lazy").setup({
  spec = vim.list_extend({
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  }, vim.list_extend(extras, {
    -- import/override with your plugins
    { import = "plugins" },
  })),
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyodark", "habamax" } },
  checker = {
    enabled = not vim.g.nvim_updates_disabled, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
