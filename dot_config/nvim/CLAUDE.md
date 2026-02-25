# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a LazyVim configuration for Neovim running on Omarchy Linux. The config extends LazyVim with custom plugins and integrations.

## Key Commands

```bash
# Lua formatting (must pass before commits)
stylua --check lua/
stylua lua/

# Track changes in chezmoi after editing
chezmoi add ~/.config/nvim/<file>

# Reload config without restarting (theme changes auto-reload)
:Lazy reload
```

## Architecture

### Config Structure
- `init.lua` - Entry point, sets up OSC 52 clipboard for terminal copy/paste
- `lua/config/lazy.lua` - Lazy.nvim bootstrap and plugin loading (only imports `lua/plugins/`)
- `lua/config/keymaps.lua` - Custom keymaps (`H`/`L` for line start/end)
- `lua/config/options.lua` - Vim options ONLY (`vim.opt.*`), NOT plugin specs
- `lua/plugins/*.lua` - Each file returns a plugin spec table, auto-loaded by lazy.nvim

**IMPORTANT**: Plugin configurations MUST go in `lua/plugins/*.lua`. Files in `lua/config/` are NOT loaded as plugin specs.

### Enabled LazyVim Extras (lazyvim.json)
AI: claudecode, copilot | Languages: typescript, angular, ember, go, rust, python, java, clangd, docker, helm, sql, markdown, json, yaml, toml, tailwind | Editor: harpoon2, aerial, dial, inc-rename | Coding: luasnip, mini-comment, mini-surround, yanky | Utils: chezmoi, rest

### Critical Plugin Interactions

**mini.operators conflict**: `gr` is remapped to `<leader>r` for LSP references because mini.operators uses `gr` for replace operator. See `nvim-lspconfig.lua` for the remapping.

**Autopairs**: Uses nvim-autopairs instead of mini.pairs. Special handling in `scheme.lua` disables quote pairing for Lisp filetypes.

**Terminal navigation**: `smart-splits.nvim` handles navigation for both kitty and tmux. It auto-detects the multiplexer via environment variables (`IS_NVIM` kitty user var, `@pane-is-vim` tmux var). Kitty config uses `--when-focus-on var:IS_NVIM` conditional mappings; tmux config uses `if -F "#{@pane-is-vim}"` bindings.

**LSP restrictions** (`lsp-fixes.lua`): Ember LSP only attaches to projects with `ember-cli-build.js`. Angular LSP only attaches with `angular.json` or `nx.json`. The Angular TS plugin is conditionally injected into vtsls.

### Omarchy Theme Integration
- `all-themes.lua` - Lazy-loads 14 colorschemes for hot-reload availability
- `omarchy-theme-hotreload.lua` - Watches for `:Lazy reload` and applies theme from `plugins/theme.lua` (external file managed by Omarchy)
- Theme changes trigger: highlight clear, colorscheme load, transparency reapplication, ColorScheme/VimEnter autocmds

### Completion (blink.cmp)
- Config in `lua/plugins/blink.lua`
- Ghost text shows inline preview, menu only on trigger chars (`.` `:`) or `<C-space>`
- Snippets prioritized (score_offset=100) but hidden after trigger characters

**IMPORTANT blink.cmp config structure:**
- `trigger.show_on_keyword` controls whether completions are **fetched** (must be true for ghost text to work)
- `menu.auto_show` controls whether menu is **displayed** (can be a function for conditional show)
- `providers` must be nested under `sources`, NOT at top level
- Use `should_show_items` on providers for contextual filtering (e.g., hide snippets after `.`)

**When modifying plugins**: Always use Context7 to look up current docs - Neovim plugin APIs change frequently and training data is often stale.

## Keybinding Conventions

- `<leader>` = Space (LazyVim default)
- `<localleader>` = `\`
- LeetCode: `\l` prefix (`\ll` list, `\lt` test, `\ls` submit)
- Obsidian notes: `<leader>o` prefix (`<leader>of` find, `<leader>od` daily, `<leader>on` new, `<leader>os` search)
- Copilot toggle: `<leader>at`
- Ctrl+h/j/k/l: tmux/kitty pane navigation
- `<C-e>` in insert/select: Finish LuaSnip snippet

## Adding New Plugins

1. Create `lua/plugins/<name>.lua` returning a spec table
2. Check for keymap conflicts with `:Lazy keys` and existing bindings
3. Consider lazy-loading (`lazy = true`, `ft`, `cmd`, `keys`, `event`)
4. Run `chezmoi add ~/.config/nvim/lua/plugins/<name>.lua`

## External Dependencies

- Omarchy manages `plugins/theme.lua` and transparency settings
- Obsidian vault: `~/Documents/notes` (shared with Obsidian app, templates in `templates/`)
- markdown_oxide LSP excluded from vault (obsidian.nvim owns it); see `nvim-lspconfig.lua`
- LeetCode uses TypeScript by default
- Conjure uses Chez Scheme for REPL
