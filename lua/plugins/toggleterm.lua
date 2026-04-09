return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = {
      "ToggleTerm",
      "TermExec",
      "ToggleLazyGit",
      "ToggleTig",
      "ToggleTigRoot",
      "ToggleTigAll",
      "ToggleNodeTerm",
      "TogglePythonTerm",
    },
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm size=12 direction=horizontal<cr>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Vertical terminal" },
      { "<leader>tg", "<cmd>ToggleLazyGit<cr>", desc = "Lazygit" },
      { "<leader>tG", "<cmd>ToggleTig<cr>", desc = "Tig (cwd)" },
      { "<leader>gt", "<cmd>ToggleTigRoot<cr>", desc = "Tig (current branch)" },
      { "<leader>gta", "<cmd>ToggleTigAll<cr>", desc = "Tig (all branches)" },
      { "<leader>gT", "<cmd>ToggleTig<cr>", desc = "Tig (cwd)" },
      { "<leader>tn", "<cmd>ToggleNodeTerm<cr>", desc = "Node terminal" },
      { "<leader>tp", "<cmd>TogglePythonTerm<cr>", desc = "Python terminal" },
    },
    opts = {
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      float_opts = {
        border = "curved",
        winblend = 0,
      },
      on_open = function(term)
        if term.direction == "float" then
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(term.bufnr) and vim.api.nvim_get_current_buf() == term.bufnr then
              vim.cmd("startinsert!")
            end
          end)
          return
        end

        local opts = { buffer = term.bufnr, silent = true }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
        vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
        vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
        vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
      end,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      local Terminal = require("toggleterm.terminal").Terminal
      local terminals = {
        lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" }),
        tig = Terminal:new({ cmd = "tig", hidden = true, direction = "float" }),
        tig_root = Terminal:new({ cmd = "tig", cwd = LazyVim.root.git(), hidden = true, direction = "float" }),
        tig_all = Terminal:new({ cmd = "tig --all", cwd = LazyVim.root.git(), hidden = true, direction = "float" }),
        node = Terminal:new({ cmd = "node", hidden = true, direction = "float" }),
        python = Terminal:new({ cmd = "python3", hidden = true, direction = "float" }),
      }

      vim.api.nvim_create_user_command("ToggleLazyGit", function()
        terminals.lazygit:toggle()
      end, {})

      vim.api.nvim_create_user_command("ToggleTig", function()
        terminals.tig:toggle()
      end, {})

      vim.api.nvim_create_user_command("ToggleTigRoot", function()
        terminals.tig_root:toggle()
      end, {})

      vim.api.nvim_create_user_command("ToggleTigAll", function()
        terminals.tig_all:toggle()
      end, {})

      vim.api.nvim_create_user_command("ToggleNodeTerm", function()
        terminals.node:toggle()
      end, {})

      vim.api.nvim_create_user_command("TogglePythonTerm", function()
        terminals.python:toggle()
      end, {})
    end,
  },
}
