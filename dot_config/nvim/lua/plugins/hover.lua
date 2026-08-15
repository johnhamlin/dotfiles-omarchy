-- Multi-provider hover on K (LSP, diagnostics, man pages, dictionary, gh).
-- K K enters the float and K again leaves it — same contract as native LSP
-- hover, so the float_navigate gd autocmd keeps working. Upstream's own
-- K-K focus logic is broken (post-rewrite it checks the legacy `hover`
-- window var; floats are now tagged `hover_preview`), so the K wrapper
-- below reimplements it on the vars enter() uses.
return {
  {
    "lewis6991/hover.nvim",
    keys = {
      {
        "K",
        function()
          if vim.w.hover_preview then
            return vim.cmd.wincmd("p")
          end
          local hover = require("hover")
          local win = vim.b.hover_preview
          if win and vim.api.nvim_win_is_valid(win) then
            hover.enter()
          else
            hover.open()
          end
        end,
        desc = "Hover (again: enter float)",
      },
      {
        "<C-n>",
        function()
          require("hover").switch("next")
        end,
        desc = "Hover (next source)",
      },
      {
        "<C-p>",
        function()
          require("hover").switch("previous")
        end,
        desc = "Hover (previous source)",
      },
    },
    opts = {
      providers = {
        "hover.providers.diagnostic",
        "hover.providers.lsp",
        "hover.providers.fold_preview",
        "hover_providers.man", -- local section-aware fork, not the stock provider
        "hover.providers.dictionary",
        "hover.providers.gh",
      },
    },
    -- Entry point is config(), not setup() (setup is a deprecated alias)
    config = function(_, opts)
      require("hover").config(opts)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    -- Function form: table-form opts would deep-extend over the "*" keys
    -- list and clobber the gr disable in nvim-lspconfig.lua
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers["*"] = opts.servers["*"] or {}
      opts.servers["*"].keys = opts.servers["*"].keys or {}
      table.insert(opts.servers["*"].keys, { "K", false })
    end,
  },
}
