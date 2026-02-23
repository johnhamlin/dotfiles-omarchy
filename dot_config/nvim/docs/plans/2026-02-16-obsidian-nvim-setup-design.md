# Obsidian.nvim Clean Setup Design

**Date:** 2026-02-16
**Status:** Approved

## Context

Migrated from vimwiki to obsidian.nvim (community fork `obsidian-nvim/obsidian.nvim`). Current config is brittle — template error on note creation, stale keybindings, incorrect completion config. Goal: rewrite to current best practices.

## Requirements

- Vault at `~/Documents/notes/` used from both Neovim and Obsidian app
- Daily journal + general note templates
- `<leader>o` keybinding prefix (replacing `\w` vimwiki legacy)
- Smart `<CR>` in vault (follow links, toggle checkboxes, create notes)
- markdown_oxide LSP excluded from vault (obsidian.nvim owns it)

## Changes

### 1. Rewrite `lua/plugins/obsidian.lua`

- Add `templates` config pointing to `templates/` folder with date/time formats
- Add `daily_notes.template = "daily.md"`
- Fix `completion` field: `nvim_cmp = true` (was incorrect `blink = true`)
- Switch all keybindings from `\w` prefix to `<leader>o` prefix
- Add smart `<CR>` via `callbacks.enter_note` buffer-local keymap
- Remove `init` function that set `maplocalleader` (already set by LazyVim)
- Remove `legacy_commands = false` (community fork uses subcommand style by default)
- Keep: `note_id_func`, `preferred_link_style`, `frontmatter`, `picker`, `attachments`, frontmatter folding autocmd, first-buffer race fix

### 2. Edit `lua/plugins/nvim-lspconfig.lua`

- Add `markdown_oxide` to `setup` section with vault exclusion (same pattern as marksman)
- Both LSPs return `nil` root_dir for files in `~/Documents/notes/`

### 3. Create vault templates

- `~/Documents/notes/templates/note.md` — frontmatter with title, date, tags
- `~/Documents/notes/templates/daily.md` — frontmatter with date + daily-notes tag, Tasks and Notes sections

### 4. No change to `lua/plugins/snacks.lua`

Dashboard button calls `:Obsidian quick_switch` directly, independent of keybindings.

## Keybinding Map

| Keybinding | Mode | Action |
|------------|------|--------|
| `<leader>of` | n | Find note (quick_switch) |
| `<leader>od` | n | Today's daily note |
| `<leader>os` | n | Search notes |
| `<leader>on` | n | New note |
| `<leader>ob` | n | Backlinks |
| `<leader>ol` | n | Outgoing links |
| `<leader>ot` | n | Find by tag |
| `<leader>oc` | n | Table of contents |
| `<leader>oD` | n | Daily notes list |
| `<leader>or` | n | Rename note |
| `<leader>op` | n | Paste image |
| `<leader>oO` | n | Open in Obsidian app |
| `<leader>ol` | v | Link to note |
| `<leader>on` | v | Link new note |
| `<leader>oe` | v | Extract note |
| `<CR>` | n | Smart action (buffer-local in vault) |
