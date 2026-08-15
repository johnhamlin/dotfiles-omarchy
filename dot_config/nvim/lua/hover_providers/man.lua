-- Section-aware fork of hover.providers.man (referenced from plugins/hover.lua).
-- Upstream hardcodes man section 1, which in C buffers resolves printf/mmap
-- to the shell-builtin pages instead of libc(3)/syscalls(2).
local api = vim.api

local sections_by_ft = {
  c = { "3", "2" },
  cpp = { "3", "2" },
  asm = { "2", "3" },
  sh = { "1" },
  zsh = { "1" },
  make = { "1" },
  tcl = { "n" },
}

--- @type Hover.Provider
return {
  name = "Man",
  priority = 150,
  enabled = function(bufnr)
    return sections_by_ft[vim.bo[bufnr].filetype] ~= nil
  end,
  execute = function(params, done)
    local word = vim.fn.expand("<cword>")
    for _, section in ipairs(sections_by_ft[vim.bo[params.bufnr].filetype]) do
      local uri = ("man://%s(%s)"):format(word, section)
      local bufnr = api.nvim_create_buf(false, true)

      local ok = pcall(api.nvim_buf_call, bufnr, function()
        api.nvim_exec_autocmds("BufReadCmd", { pattern = uri })
      end)

      if ok and api.nvim_buf_line_count(bufnr) > 1 then
        -- Re-run BufReadCmd once displayed so :Man reflows to the float width
        api.nvim_create_autocmd("BufWinEnter", {
          buffer = bufnr,
          once = true,
          callback = function()
            api.nvim_exec_autocmds("BufReadCmd", { pattern = uri })
          end,
        })
        return done({ bufnr = bufnr })
      end
      api.nvim_buf_delete(bufnr, { force = true })
    end
    done()
  end,
}
