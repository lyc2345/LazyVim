return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local function use_snacks_projects()
        Snacks.picker.projects()
      end

      local function select_session()
        require("persistence").select()
      end

      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.projects = vim.tbl_deep_extend("force", opts.picker.sources.projects or {}, {
        confirm = { "tcd", "picker_explorer" },
      })
      opts.picker.sources.explorer = vim.tbl_deep_extend("force", opts.picker.sources.explorer or {}, {
        hidden = true,
        ignored = true,
      })

      if opts.dashboard and opts.dashboard.preset and opts.dashboard.preset.keys then
        opts.dashboard.preset.keys = vim.tbl_filter(function(item)
          return item.key ~= "P" and item.key ~= "p" and item.key ~= "S"
        end, opts.dashboard.preset.keys)

        table.insert(opts.dashboard.preset.keys, 3, {
          icon = " ",
          key = "P",
          desc = "Projects",
          action = use_snacks_projects,
        })
        table.insert(opts.dashboard.preset.keys, 7, {
          icon = " ",
          key = "S",
          desc = "Select Session",
          action = select_session,
        })
      end
    end,
    keys = {
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Go to left split/pane" },
      { "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Go to lower split/pane" },
      { "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Go to upper split/pane" },
      { "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Go to right split/pane" },
      { "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Go to previous split/pane" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>d", group = "debug" },
        { "<leader>dP", group = "python debug" },
        { "<leader>n", group = "number" },
        { "<leader>t", group = "terminal" },
      },
    },
  },
  {
    "folke/trouble.nvim",
    optional = true,
    keys = {
      { "<leader>xo", "<cmd>Trouble diagnostics open<cr>", desc = "Open Diagnostics" },
      { "<leader>xc", "<cmd>Trouble diagnostics close<cr>", desc = "Close Diagnostics" },
      { "<leader>xO", "<cmd>Trouble diagnostics open filter.buf=0<cr>", desc = "Open Buffer Diagnostics" },
    },
  },
}
