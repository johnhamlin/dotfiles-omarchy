return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("minuet").setup({
      -- Use Claude by default (switch with :Minuet change_provider openai)
      provider = "claude",
      provider_options = {
        claude = {
          model = "claude-sonnet-4-20250514",
          api_key = "ANTHROPIC_API_KEY", -- reads from env var
        },
        openai = {
          model = "gpt-4o",
          api_key = "OPENAI_API_KEY", -- reads from env var
        },
      },

      -- Virtual text (ghost text) configuration
      virtualtext = {
        auto_trigger_ft = {}, -- Empty = manual trigger only
        keymap = {
          -- Accept suggestions
          accept = "<A-l>", -- Alt+l to accept all
          accept_line = "<A-j>", -- Alt+j to accept one line

          -- Cycle through suggestions
          next = "<A-]>", -- Alt+] next suggestion
          prev = "<A-[>", -- Alt+[ previous suggestion

          -- Dismiss
          dismiss = "<A-e>", -- Alt+e dismiss
        },
      },

      -- Disable completion menu integrations (virtual text only)
      cmp = { enable_auto_complete = false },
      blink = { enable_auto_complete = false },

      -- Performance
      request_timeout = 5,
      throttle = 500,
      debounce = 300,
      n_completions = 3,
    })
  end,
  keys = {
    -- Manual trigger in insert mode (next() triggers if no suggestions exist)
    {
      "<C-\\>",
      function()
        require("minuet.virtualtext").action.next()
      end,
      mode = "i",
      desc = "Trigger AI Suggestion",
    },
    -- Toggle auto-trigger mode
    {
      "<leader>at",
      "<cmd>Minuet virtualtext toggle<cr>",
      desc = "Toggle AI Auto-Trigger",
    },
    -- Switch provider
    {
      "<leader>ap",
      "<cmd>Minuet change_provider<cr>",
      desc = "Change AI Provider",
    },
  },
}
