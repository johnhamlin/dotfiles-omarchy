return {
  -- Automatic list continuation: `-` lists, `1.` renumbering, `- [ ]` checkboxes.
  -- Neovim's runtime ftplugin/markdown.vim does `formatoptions-=r` and marks the
  -- list leaders `f` in 'comments', so built-in continuation can't work here.
  -- bullets.vim does it via its own <CR> map instead of 'formatoptions'.
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown", "text", "gitcommit" },
    init = function()
      -- Gates the buffer-local <CR> map to these filetypes, so nvim-autopairs
      -- keeps its global <CR> (newline-in-pair indent) everywhere else.
      vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
      vim.g.bullets_renumber_on_change = 1
      vim.g.bullets_nested_checkboxes = 1
    end,
  },
}
