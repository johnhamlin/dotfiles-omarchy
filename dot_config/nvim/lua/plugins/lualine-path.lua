return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    -- In current LazyVim, the path is in lualine_c, usually index 4.
    -- Replace the default pretty_path with one that allows more segments.
    opts.sections.lualine_c[4] = {
      LazyVim.lualine.pretty_path({
        length = 6, -- default is 3; bump this up
        -- you can also play with:
        -- relative = "cwd", -- or "root"
        -- modified_hl = "WarningMsg",
      }),
    }
  end,
}
