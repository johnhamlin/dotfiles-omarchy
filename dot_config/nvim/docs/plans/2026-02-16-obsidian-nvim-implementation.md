# Obsidian.nvim Clean Setup — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace brittle obsidian.nvim config with a clean setup following current community fork best practices.

**Architecture:** Rewrite `lua/plugins/obsidian.lua` with correct opts, `<leader>o` keybindings, smart `<CR>`, and templates. Scope markdown_oxide LSP away from vault. Create two vault templates.

**Tech Stack:** obsidian-nvim/obsidian.nvim (community fork), LazyVim, snacks.pick, blink.cmp

**Design doc:** `docs/plans/2026-02-16-obsidian-nvim-setup-design.md`

---

### Task 1: Create vault templates directory and files

**Files:**
- Create: `~/Documents/notes/templates/daily.md`
- Create: `~/Documents/notes/templates/note.md`

**Step 1: Create templates directory**

Run: `mkdir -p ~/Documents/notes/templates`

**Step 2: Create daily note template**

Write `~/Documents/notes/templates/daily.md`:

```markdown
---
title: "{{date}}"
date: {{date}}
tags: [daily-notes]
---

# {{date}}

## Tasks
- [ ]

## Notes

```

**Step 3: Create general note template**

Write `~/Documents/notes/templates/note.md`:

```markdown
---
title: "{{title}}"
date: {{date}}
tags: []
---

# {{title}}
```

**Step 4: Verify templates exist**

Run: `ls -la ~/Documents/notes/templates/`
Expected: `daily.md` and `note.md` both present.

**Step 5: Commit**

```bash
cd ~/Documents/notes
git add templates/daily.md templates/note.md
git commit -m "feat: add obsidian note templates for daily and general notes"
```

---

### Task 2: Rewrite obsidian.nvim plugin config

**Files:**
- Rewrite: `~/.config/nvim/lua/plugins/obsidian.lua` (entire file, 104 lines)

**Step 1: Write the new obsidian.lua**

Replace the entire file with:

```lua
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

    -- Fix first-buffer race: BufEnter fires before BufReadPre, so the
    -- plugin's BufEnter autocmd (registered on FileType) misses the
    -- initial buffer. Re-trigger after the event loop settles.
    local buf = vim.api.nvim_get_current_buf()
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
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
      nvim_cmp = true,
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
    frontmatter = { enabled = true },
    note_id_func = function(title)
      if title then
        return title
      end
      return tostring(os.time())
    end,
    callbacks = {
      enter_note = function(_, _)
        vim.keymap.set("n", "<CR>", function()
          if require("obsidian").api.smart_action() then
            return
          end
          -- Fall back to normal Enter
          local enter = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
          vim.api.nvim_feedkeys(enter, "n", false)
        end, { buffer = true, desc = "Obsidian smart action" })
      end,
    },
  },
}
```

**Step 2: Run stylua to format**

Run: `stylua ~/.config/nvim/lua/plugins/obsidian.lua`

**Step 3: Verify formatting passes**

Run: `stylua --check ~/.config/nvim/lua/plugins/obsidian.lua`
Expected: No output (clean exit).

---

### Task 3: Scope markdown_oxide LSP away from vault

**Files:**
- Modify: `~/.config/nvim/lua/plugins/nvim-lspconfig.lua:27-41` (add to `setup` table)

**Step 1: Add markdown_oxide setup function**

After the `marksman` entry in the `setup` table (line 40), add:

```lua
markdown_oxide = function(_, server_opts)
  local orig_root = require("lspconfig.util").root_pattern(".git")
  server_opts.root_dir = function(bufnr_or_fname)
    local fname = type(bufnr_or_fname) == "number"
      and vim.api.nvim_buf_get_name(bufnr_or_fname)
      or bufnr_or_fname
    if fname:find(vim.fn.expand("~/Documents/notes"), 1, true) then
      return nil
    end
    return orig_root(fname)
  end
  return false
end,
```

**Step 2: Run stylua to format**

Run: `stylua ~/.config/nvim/lua/plugins/nvim-lspconfig.lua`

**Step 3: Verify formatting passes**

Run: `stylua --check ~/.config/nvim/lua/plugins/nvim-lspconfig.lua`
Expected: No output (clean exit).

---

### Task 4: Validate full config and commit

**Step 1: Run stylua check on all Lua files**

Run: `stylua --check ~/.config/nvim/lua/`
Expected: Clean exit, no formatting errors.

**Step 2: Verify Neovim loads config without errors**

Run: `nvim --headless -c "lua print('Config loaded OK')" -c "qa!" 2>&1`
Expected: "Config loaded OK" with no errors.

**Step 3: Verify obsidian.nvim plugin is recognized by lazy.nvim**

Run: `nvim --headless -c "lua local ok, _ = pcall(require, 'lazy'); if ok then for _, p in ipairs(require('lazy').plugins()) do if p.name == 'obsidian.nvim' then print('obsidian.nvim: found') end end end" -c "qa!" 2>&1`
Expected: "obsidian.nvim: found"

**Step 4: Update CLAUDE.md if needed**

Check if CLAUDE.md references vimwiki keybindings (`\w` prefix) — if so, update to document the new `<leader>o` prefix and remove vimwiki references.

**Step 5: Chezmoi tracking**

Run:
```bash
chezmoi add ~/.config/nvim/lua/plugins/obsidian.lua
chezmoi add ~/.config/nvim/lua/plugins/nvim-lspconfig.lua
```

---

### Task 5: Update CLAUDE.md project documentation

**Files:**
- Modify: `~/.config/nvim/CLAUDE.md`

**Step 1: Update keybinding conventions section**

Replace VimWiki references with Obsidian:
- Remove: `VimWiki: \w prefix`
- Add: `Obsidian notes: <leader>o prefix (<leader>of find, <leader>od daily, <leader>on new)`

**Step 2: Update external dependencies section**

- Remove or update: `VimWiki path: /home/john/Documents/vimwiki`
- Add: `Obsidian vault: ~/Documents/notes (shared with Obsidian app)`

**Step 3: Run stylua check**

Run: `stylua --check ~/.config/nvim/lua/`
Expected: Clean.

**Step 4: Chezmoi tracking**

Run: `chezmoi add ~/.config/nvim/CLAUDE.md`
