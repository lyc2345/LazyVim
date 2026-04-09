-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode.
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("user_highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local number_group = vim.api.nvim_create_augroup("user_number_mode", { clear = true })

local function set_relative_number(enabled)
  if vim.bo.buftype == "" then
    vim.wo.number = true
    vim.wo.relativenumber = enabled
  end
end

vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  desc = "Use absolute line numbers in insert mode",
  group = number_group,
  callback = function()
    set_relative_number(false)
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "FocusGained", "WinEnter" }, {
  desc = "Restore relative line numbers in normal mode",
  group = number_group,
  callback = function()
    set_relative_number(true)
  end,
})

vim.api.nvim_create_user_command("ReloadConfig", function()
  for name in pairs(package.loaded) do
    if name == "config.options" or name == "config.keymaps" or name == "config.autocmds" then
      package.loaded[name] = nil
    end
  end

  require("config.options")
  require("config.keymaps")
  require("config.autocmds")

  vim.notify("Core config reloaded. Restart Neovim for plugin spec changes.", vim.log.levels.INFO)
end, { desc = "Reload Neovim config" })
