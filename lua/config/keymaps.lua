-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap.set

-- Basic keymaps
keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- increment/decrement numbers
keymap("n", "<leader>n+", "<C-a>", { desc = "Increment number" })
keymap("n", "<leader>n-", "<C-x>", { desc = "Decrement number" })

-- window management
keymap("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
keymap("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
keymap("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" })
keymap("n", "<leader>wx", "<cmd>close<cr>", { desc = "Close current split" })

-- NOTE: Some terminals cannot send distinct keycodes for Ctrl+Shift+key.
keymap("n", "<C-S-h>", "<C-w>H", { desc = "Move window left" })
keymap("n", "<C-S-j>", "<C-w>J", { desc = "Move window down" })
keymap("n", "<C-S-k>", "<C-w>K", { desc = "Move window up" })
keymap("n", "<C-S-l>", "<C-w>L", { desc = "Move window right" })

-- Resize windows
keymap("n", "<C-Left>", "<C-w><", { desc = "Resize window narrower" })
keymap("n", "<C-Right>", "<C-w>>", { desc = "Resize window wider" })
keymap("n", "<C-Up>", "<C-w>+", { desc = "Resize window taller" })
keymap("n", "<C-Down>", "<C-w>-", { desc = "Resize window shorter" })
