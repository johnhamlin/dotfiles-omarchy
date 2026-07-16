# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a LazyVim configuration for Neovim running on CachyOS + HyDE. The config extends LazyVim with custom plugins and integrations.

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

**Autopairs**: Uses nvim-autopairs instead of mini.pairs. Special handling in `lisp.lua` disables quote pairing for Lisp filetypes.

**Terminal navigation**: `smart-splits.nvim` handles Ctrl+hjkl navigation for kitty, tmux and zellij. The plugin *can* auto-detect the multiplexer, but **`smart-splits.lua` overrides that** — its `mux()` helper names the backend explicitly from `$ZELLIJ` / `$TMUX` / `$KITTY_LISTEN_ON`, because passing `multiplexer_integration` at all (even `false`) makes the plugin skip its own auto-detect. Do not "simplify" `mux()` to return `false` for the bare-terminal case: in kitty that disables the edge hop out of nvim into kitty splits while leaving nvim-internal splits working, which is a confusing one-sided failure. Signalling: `IS_NVIM` kitty user var (written by the kitty backend's `on_init`, keyed off by `--when-focus-on var:IS_NVIM` maps in `kitty/custom.conf`); `@pane-is-vim` tmux var (`if -F "#{@pane-is-vim}"` bindings). `at_edge = "stop"` under kitty is deliberate — the mux hop is attempted before `at_edge` is consulted, and kitty can't wrap. Full write-up: `~/notes/nvim-kitty-split-nav-2026-07-16.md`.

**LSP restrictions** (`lsp-fixes.lua`): Ember LSP only attaches to projects with `ember-cli-build.js`. Angular LSP only attaches with `angular.json` or `nx.json`. The Angular TS plugin is conditionally injected into vtsls.

### Theme
- `theme.lua` - Sets tokyonight-night colorscheme

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

- Obsidian vault: `~/Nextcloud/Obsidian` (Nextcloud-synced, shared with Obsidian app, templates in `templates/`)
- markdown_oxide LSP excluded from vault (obsidian.nvim owns it); see `nvim-lspconfig.lua`
- LeetCode uses TypeScript by default
- Conjure uses Chez Scheme for REPL
