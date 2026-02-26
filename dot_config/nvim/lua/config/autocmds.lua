-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Make blink.cmp ghost text brighter and more visible across all themes
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("custom_ghost_text", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = "#9eaed0", italic = true })
  end,
})
-- Apply immediately for current theme
vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = "#9eaed0", italic = true })

-- Fix: first file opened from Snacks dashboard missing LSP/treesitter/completions.
-- Filetype detection doesn't run for the first file, so treesitter and LSP never attach.
-- This re-triggers detection on the first real file, then removes itself.
-- TODO: this is a workaround, not a root-cause fix. The real bug is likely in lazy.nvim
-- or Snacks dashboard event handling. obsidian.lua:32-41 has a similar workaround that
-- could potentially be removed if this general fix covers it (needs testing).
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("fix_dashboard_first_file", { clear = true }),
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
      return
    end
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if vim.bo[buf].filetype == "" then
        vim.cmd.filetype("detect")
      end
      if vim.bo[buf].filetype ~= "" then
        vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
      end
    end)
    return true -- self-removing
  end,
})

-- Navigate to symbols from hover/diagnostic floating windows.
-- When focused in a hover float (K K), gd grabs the word under cursor
-- and searches workspace symbols for it.
vim.api.nvim_create_autocmd("WinEnter", {
  group = vim.api.nvim_create_augroup("float_navigate", { clear = true }),
  desc = "Add gd to hover/diagnostic floats for type navigation",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(win)
    if config.relative == "" then
      return
    end

    local buf = vim.api.nvim_win_get_buf(win)
    if vim.b[buf]._float_nav then
      return
    end
    if vim.bo[buf].modifiable then
      return
    end

    vim.b[buf]._float_nav = true
    vim.keymap.set("n", "gd", function()
      local word = vim.fn.expand("<cword>")
      pcall(vim.api.nvim_win_close, 0, true)
      vim.schedule(function()
        Snacks.picker.lsp_workspace_symbols({ query = word })
      end)
    end, { buffer = buf, desc = "Jump to symbol from hover" })
  end,
})
