-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Note: Plugin specs belong in lua/plugins/*.lua, not here
-- This file is for vim.opt.* settings only

-- Dedicated python host for remote plugins (molten-nvim); has pynvim + jupyter_client
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/nvim/bin/python")

vim.api.nvim_create_autocmd("FileType", {
  desc = "Don't continue comments with o/O",
  callback = function()
    vim.opt_local.formatoptions:remove("o")
  end,
})

