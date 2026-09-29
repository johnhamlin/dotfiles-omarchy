-- This project uses vasm oldstyle; keep all other assembly detection unchanged.
local root = vim.fs.normalize(vim.fn.expand("~/Nextcloud/⚡️ Electronics/6502/code"))
local function in_project(path)
  path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
  return path:sub(1, #root + 1) == root .. "/"
end

return {
  "neovim/nvim-lspconfig",
  init = function()
    vim.filetype.add({
      pattern = {
        [vim.pesc(root) .. "/.*"] = {
          function(path)
            local ext = path:match("%.([^./]+)$")
            if in_project(path) and vim.tbl_contains({ "s", "S", "asm", "inc" }, ext) then
              return "vasm6502"
            end
          end,
          { priority = 1000 },
        },
      },
    })
  end,
  opts = {
    servers = {
      -- Installing the binary must not auto-enable a new server for x86 files.
      asm_lsp = { enabled = false },
      -- Separate client name so future x86 asm_lsp settings stay independent.
      vasm6502 = {
        mason = false,
        cmd = { vim.fn.stdpath("data") .. "/mason/bin/asm-lsp" },
        filetypes = { "vasm6502" },
        root_dir = function(bufnr, on_dir)
          if in_project(vim.api.nvim_buf_get_name(bufnr)) then
            on_dir(root)
          end
        end,
      },
    },
  },
}
