return {
  -- Treesitter for Scheme
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { "scheme" })
    end,
  },

  -- Rainbow parens for lisps
  {
    "HiPhish/rainbow-delimiters.nvim",
    ft = { "scheme", "racket", "lisp", "clojure" },
    config = function()
      local rainbow = require("rainbow-delimiters")
      require("rainbow-delimiters.setup").setup({
        query = {
          ["scheme"] = "rainbow-delimiters",
          ["racket"] = "rainbow-delimiters",
        },
      })
    end,
  },

  -- Conjure + Chez
  {
    "Olical/conjure",
    ft = { "scheme", "racket" },
    keys = {
      {
        "<localleader>d",
        function()
          vim.cmd("silent! write")
          vim.fn.jobstart({ "drracket", vim.api.nvim_buf_get_name(0) }, { detach = true })
        end,
        ft = { "scheme", "racket" },
        desc = "Open in DrRacket",
      },
      {
        "<localleader>t",
        function()
          vim.cmd("silent! write")
          vim.cmd("split | terminal raco test " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))
          vim.bo.buflisted = false
          vim.bo.bufhidden = "wipe"
        end,
        ft = { "scheme", "racket" },
        desc = "Run tests (raco test)",
      },
    },
    init = function()
      vim.g["conjure#client#scheme#stdio#command"] = "chez"
      vim.g["conjure#client#scheme#stdio#prompt_pattern"] = "> $?"
      -- Log behaviour
      -- vim.g["conjure#log#hud#enabled"] = false -- use split log, not HUD
      -- vim.g["conjure#log#wrap"] = true -- nicer wrapping
      -- vim.g["conjure#log#botright"] = true -- put log at bottom / right
      -- vim.g["conjure#log#on_eval"] = true -- ⬅ auto-show log on eval
    end,
  },

  -- Autopairs tweak: no ' pairing in lisps
  {
    "windwp/nvim-autopairs",
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.setup(opts)

      pcall(function()
        npairs.remove_rule("'")
      end)

      npairs.add_rules({
        Rule("'", "'")
          :with_pair(cond.not_filetypes({ "scheme", "racket", "lisp", "clojure" }))
          :with_pair(cond.not_before_regex("%w")),
      })
    end,
  },

  -- Parinfer for lisps
  {
    "gpanders/nvim-parinfer",
    ft = { "scheme", "racket", "lisp", "clojure" },
  },

  -- S-expression editing
  {
    "guns/vim-sexp",
    dependencies = {
      "tpope/vim-repeat",
      "tpope/vim-surround",
    },
    ft = { "scheme", "racket", "lisp", "clojure" },
  },
  {
    "tpope/vim-sexp-mappings-for-regular-people",
    ft = { "scheme", "racket", "lisp", "clojure" },
  },
}
