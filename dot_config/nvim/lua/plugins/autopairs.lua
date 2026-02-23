return {
  -- Disable mini.pairs
  { "nvim-mini/mini.pairs", enabled = false },

  -- Use nvim-autopairs instead
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true, -- Use treesitter to check for pairs
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
    },
  },
}
