-- Jupyter notebooks: molten-nvim (kernel exec + inline output) + image.nvim
-- (kitty graphics for plots) + jupytext.nvim (.ipynb <-> markdown) + quarto/otter
-- (LSP + cell runner inside markdown code cells; render-markdown from the
-- lang.markdown extra paints the prose). Host python: ~/.venvs/nvim (see
-- config/options.lua). Kernels are per-project:
--   uv venv && uv pip install ipykernel <deps>
--   .venv/bin/python -m ipykernel install --user --name <name>
-- then :MoltenInit <name> in the buffer.
return {
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      processor = "magick_cli", -- system imagemagick; avoids the magick luarock
      max_width = 100,
      max_height = 20,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },
  {
    "benlubas/molten-nvim",
    version = "^1",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_wrap_output = true
    end,
    keys = {
      { "<localleader>mi", ":MoltenInit<CR>", desc = "Molten init kernel" },
      { "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", desc = "Molten open output" },
      { "<localleader>oh", ":MoltenHideOutput<CR>", desc = "Molten hide output" },
      { "<localleader>md", ":MoltenDelete<CR>", desc = "Molten delete cell" },
    },
  },
  {
    "quarto-dev/quarto-nvim",
    dependencies = { "jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter" },
    ft = { "quarto", "markdown" },
    opts = {
      lspFeatures = {
        languages = { "python" },
        chunks = "all",
        diagnostics = { enabled = true, triggers = { "BufWritePost" } },
        completion = { enabled = true },
      },
      codeRunner = { enabled = true, default_method = "molten" },
    },
    config = function(_, opts)
      require("quarto").setup(opts)
      -- Activate quarto/otter only in jupytext-backed notebook buffers, NOT
      -- every markdown file (obsidian notes etc. must stay untouched).
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(ev)
          if vim.fn.fnamemodify(ev.file, ":e") == "ipynb" then
            require("quarto").activate()
          end
        end,
      })
    end,
    keys = (function()
      -- quarto.runner calls vim.fn.MoltenEvaluateRange() directly, which is a
      -- SILENT no-op when no kernel is attached (only molten's user commands
      -- auto-prompt). Guard: no kernel -> open the init prompt instead.
      local function run(method)
        return function()
          local attached = vim.fn.exists("*MoltenStatusLineKernels") == 1
            and vim.fn.MoltenStatusLineKernels(true) or ""
          if attached == "" then
            vim.notify("Molten: no kernel attached — pick one, then rerun", vim.log.levels.WARN)
            vim.cmd("MoltenInit")
            return
          end
          require("quarto.runner")[method]()
        end
      end
      return {
        { "<localleader>rc", run("run_cell"), desc = "Run cell" },
        { "<localleader>ra", run("run_above"), desc = "Run cell and above" },
        { "<localleader>rA", run("run_all"), desc = "Run all cells" },
        { "<localleader>rl", run("run_line"), desc = "Run line" },
        { "<localleader>r", run("run_range"), mode = "v", desc = "Run visual range" },
      }
    end)(),
  },
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false, -- must register its BufReadCmd for *.ipynb before one is opened
    init = function()
      -- jupytext.nvim can't open a notebook that doesn't exist on disk yet
      -- (utils.lua indexes io.open() without a nil check). Seed brand-new
      -- .ipynb paths with a minimal valid notebook before its BufReadCmd runs;
      -- this autocmd must be registered before the plugin's (init runs first).
      local default_notebook = table.concat({
        '{"cells":[{"cell_type":"markdown","metadata":{},"source":[""]}],',
        '"metadata":{"kernelspec":{"display_name":"Python 3","language":"python","name":"python3"},',
        '"language_info":{"file_extension":".py","name":"python"}},',
        '"nbformat":4,"nbformat_minor":5}',
      })
      local function seed(path)
        local file = io.open(path, "w")
        if not file then
          return false
        end
        file:write(default_notebook)
        file:close()
        return true
      end
      vim.api.nvim_create_autocmd("BufReadCmd", {
        pattern = "*.ipynb",
        callback = function(ev)
          if vim.fn.getfsize(ev.file) <= 0 then -- missing (-1) or empty (0) file
            seed(ev.file)
          end
          -- BufReadCmd replaces the whole read pipeline, so BufReadPre never
          -- fires for notebooks; emulate it so event-gated plugins (LazyVim
          -- loads nvim-lspconfig on BufReadPre) still load. This autocmd runs
          -- before jupytext's, matching the normal pre-read timing.
          vim.api.nvim_exec_autocmds("BufReadPre", { pattern = ev.file, modeline = false })
        end,
      })
      vim.api.nvim_create_user_command("NewNotebook", function(opts)
        local path = opts.args:gsub("%.ipynb$", "") .. ".ipynb"
        if seed(path) then
          vim.cmd.edit(path)
        else
          vim.notify("NewNotebook: cannot write " .. path, vim.log.levels.ERROR)
        end
      end, { nargs = 1, complete = "file" })
    end,
    opts = {
      style = "markdown", -- markdown cells render as real markdown (quarto/otter give cell LSP)
      output_extension = "md",
      force_ft = "markdown",
    },
  },
}
