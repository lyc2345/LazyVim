return {
  {
    "yetone/avante.nvim",
    opts = {
      provider = "codex",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-5-20250929",
          timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 64000,
          },
        },
      },
      acp_providers = {
        codex = {
          command = "npx",
          args = { "@zed-industries/codex-acp" },
          env = {
            NODE_NO_WARNINGS = "1",
            OPENAI_API_KEY = os.getenv("AVANTE_OPENAI_API_KEY") or os.getenv("OPENAI_API_KEY"),
          },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "ai" },
      },
    },
  },
}
