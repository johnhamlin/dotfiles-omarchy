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
      {
        "<leader>kh",
        function()
          local cur = vim.api.nvim_get_current_win()
          local float = vim.w.hover_preview and cur or vim.b.hover_preview
          if not (float and vim.api.nvim_win_is_valid(float)) then
            return vim.notify("no hover float open", vim.log.levels.INFO)
          end
          -- Move the float's buffer into a split instead of copying lines:
          -- a man float keeps its Man ftplugin maps, an LSP float its
          -- markdown treesitter. bufhidden=wipe would kill the buffer at
          -- win_close, so lift it for the handover and restore after.
          local buf = vim.api.nvim_win_get_buf(float)
          vim.bo[buf].bufhidden = "hide"
          vim.api.nvim_win_close(float, true)
          vim.cmd("split")
          vim.api.nvim_win_set_buf(0, buf)
          vim.bo[buf].bufhidden = "wipe"
        end,
        desc = "Promote hover to split",
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
