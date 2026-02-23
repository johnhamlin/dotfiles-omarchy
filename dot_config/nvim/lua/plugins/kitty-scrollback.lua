return {
  "mikesmithgh/kitty-scrollback.nvim",
  lazy = true,
  cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
  event = { "User KittyScrollbackLaunch" },
  config = function()
    require("kitty-scrollback").setup({
      -- Use Esc to quit (previous default behavior)
      keymaps_enabled = true,
    })
    vim.keymap.set({ "n" }, "<Esc>", "<Plug>(KsbCloseOrQuitAll)", {})
  end,
}
