return {
  -- This name matches the plugin from the LazyVim "extra"
  "snacks.nvim",

  -- The `opts` function will receive the default options,
  -- including the `opts.dashboard.preset.keys` table.
  opts = function(_, opts)
    local notes_button = {
      icon = "󰂺 ", -- Nerd Font icon (nf-md-book_open_variant)
      key = "w",
      desc = "Notes",
      action = ":Obsidian quick_switch",
    }

    table.insert(opts.dashboard.preset.keys, 3, notes_button)

    return opts
  end,

  keys = {
    {
      "<leader>fI",
      function()
        Snacks.picker.files({ ignored = true, hidden = true })
      end,
      desc = "Find Files (incl. ignored)",
    },
  },
}
