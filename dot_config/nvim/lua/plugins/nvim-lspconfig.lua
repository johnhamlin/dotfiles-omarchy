return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          -- Remap because of mini.operators conflict
          { "gr", false },
          {
            "<leader>r",
            function()
              Snacks.picker.lsp_references()
            end,
            nowait = true,
            desc = "References",
          },
        },
      },
      markdown_oxide = {
        capabilities = {
          workspace = {
            didChangeWatchedFiles = { dynamicRegistration = true },
          },
        },
      },
    },
    setup = {
      marksman = function(_, server_opts)
        local orig_root = require("lspconfig.util").root_pattern(".marksman.toml", ".git")
        server_opts.root_dir = function(bufnr_or_fname)
          local fname = type(bufnr_or_fname) == "number" and vim.api.nvim_buf_get_name(bufnr_or_fname) or bufnr_or_fname
          if fname:find(vim.fn.expand("~/Documents/notes"), 1, true) then
            return nil
          end
          return orig_root(fname)
        end
        return false
      end,
    },
  },
}
