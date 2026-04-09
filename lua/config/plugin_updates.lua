local M = {}

local local_config_path = vim.fn.stdpath("config") .. "/lua/config/local.lua"
local local_config = {}
local ok, loaded = pcall(require, "config.local")
if ok and type(loaded) == "table" then
  local_config = loaded
end

vim.g.nvim_updates_disabled = local_config.nvim_updates_disabled == true

function M.disabled()
  return vim.g.nvim_updates_disabled == true
end

function M.enabled()
  return not M.disabled()
end

function M.set(enabled)
  vim.g.nvim_updates_disabled = not enabled
  local fd = assert(io.open(local_config_path, "w"))
  fd:write("-- Machine-specific settings. This file is intentionally ignored by git.\n\n")
  fd:write("return {\n")
  fd:write(("  nvim_updates_disabled = %s,\n"):format(enabled and "false" or "true"))
  fd:write("}\n")
  fd:close()

  local ok_config, Config = pcall(require, "lazy.core.config")
  if ok_config then
    Config.options.checker.enabled = enabled
  end
end

function M.toggle()
  local enabled = not M.enabled()
  M.set(enabled)
  return enabled
end

function M.status_text()
  return M.enabled() and "enabled" or "disabled"
end

function M.local_config_path()
  return local_config_path
end

return M
