return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  event = {
    "BufReadPre " .. vim.fn.expand("~") .. "/Documents/notes/**.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/Documents/notes/**.md",
  },
  cmd = { "Obsidian" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>of", "<cmd>Obsidian quick_switch<cr>", desc = "Find note" },
    { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search notes" },
    { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
    { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Outgoing links" },
    { "<leader>ot", "<cmd>Obsidian tags<cr>", desc = "Find by tag" },
    { "<leader>oc", "<cmd>Obsidian toc<cr>", desc = "Table of contents" },
    { "<leader>oD", "<cmd>Obsidian dailies<cr>", desc = "Daily notes list" },
    { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
    { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },
    { "<leader>oO", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian app" },
    { "<leader>ol", ":Obsidian link<cr>", mode = "v", desc = "Link to note" },
    { "<leader>on", ":Obsidian link_new<cr>", mode = "v", desc = "Link new note" },
    { "<leader>oe", ":Obsidian extract_note<cr>", mode = "v", desc = "Extract note" },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    -- Fix first-buffer race: the plugin's FileType autocmd (which registers
    -- per-buffer BufEnter for LSP) hasn't fired yet for the initial buffer.
    -- Re-trigger FileType first (registers autocmds), then BufEnter (starts LSP).
    local buf = vim.api.nvim_get_current_buf()
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_exec_autocmds("FileType", { buffer = buf })
        vim.api.nvim_exec_autocmds("BufEnter", { buffer = buf })
      end
    end)

    -- Auto-fold frontmatter in markdown files
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = vim.api.nvim_create_augroup("ObsidianFoldFrontmatter", { clear = true }),
      pattern = "*.md",
      callback = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
        if #lines == 0 or lines[1] ~= "---" then
          return
        end
        local line_count = vim.api.nvim_buf_line_count(0)
        for i = 2, math.min(line_count, 30) do
          local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
          if line == "---" then
            vim.wo.foldmethod = "manual"
            vim.cmd(("1,%dfold"):format(i))
            return
          end
        end
      end,
    })
  end,
  opts = {
    workspaces = {
      {
        name = "notes",
        path = "~/Documents/notes",
      },
    },
    daily_notes = {
      folder = "diary",
      date_format = "%Y-%m-%d",
      template = "daily.md",
    },
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },
    completion = {
      blink = true,
      min_chars = 2,
    },
    attachments = {
      folder = "attachments",
    },
    picker = {
      name = "snacks.pick",
      note_mappings = {
        new = "<C-x>",
        insert_link = "<C-l>",
      },
      tag_mappings = {
        tag_note = "<C-x>",
        insert_tag = "<C-l>",
      },
    },
    preferred_link_style = "wiki",
    legacy_commands = false,
    frontmatter = { enabled = true },
    note_id_func = function(title)
      if title then
        return title
      end
      return tostring(os.time())
    end,
  },
}
