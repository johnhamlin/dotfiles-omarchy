# Fish Shell Keyboard Shortcuts & Productivity Reference

## 1. Fuzzy Search (fzf.fish) — your biggest productivity lever

Installed system-wide by omarchy-fish. These work in both insert and normal mode.

| Shortcut | What it does | Mnemonic |
|---|---|---|
| **Ctrl+R** | Fuzzy search command history, insert selection | **R**everse search |
| **Ctrl+Alt+F** | Fuzzy find files in current dir (recursive), insert path | **F**ile |
| **Ctrl+Alt+L** | Fuzzy search git log, insert commit hash | **L**og |
| **Ctrl+Alt+S** | Fuzzy search git status, insert changed file path | **S**tatus |
| **Ctrl+V** | Fuzzy search shell variables, insert selection | **V**ariable |
| **Ctrl+Alt+P** | Search processes (DISABLED by omarchy config) | Process |

Tips:
- **Tab** to multi-select entries in any fzf search
- Start typing before hitting the shortcut to seed the fzf query
- In file search, if cursor is on a `directory/`, it searches inside that directory
- Directories are inserted with trailing `/` so you can immediately `Enter` to cd

## 2. Your Custom Keybindings (config.fish)

| Shortcut | What it does | Source |
|---|---|---|
| **Ctrl+P** | History prefix search backward (type partial cmd, then Ctrl+P to cycle matches) | config.fish |
| **Ctrl+N** | History prefix search forward | config.fish |
| **Ctrl+.** | Accept next word of autosuggestion (requires kitty keybind) | config.fish |
| **Ctrl+S** | Toggle `sudo` prefix on current command | config.fish |

## 3. Fish Built-in Keybindings (insert mode)

These work regardless of plugins:

| Shortcut | What it does |
|---|---|
| **Tab** | Autocomplete (cycle through completions) |
| **Shift+Tab** | Cycle completions backward |
| **Right Arrow** | Accept full autosuggestion |
| **Alt+Right** | Accept next word of autosuggestion |
| **Ctrl+F** | Accept full autosuggestion (same as Right) |
| **Alt+F** | Accept next word of autosuggestion |
| **Ctrl+C** | Cancel current command line |
| **Ctrl+D** | Delete char or exit if line is empty |
| **Ctrl+U** | Delete from cursor to beginning of line |
| **Ctrl+K** | Delete from cursor to end of line |
| **Ctrl+W** | Delete previous word |
| **Alt+D** | Delete next word |
| **Ctrl+A** | Move cursor to beginning of line |
| **Ctrl+E** | Move cursor to end of line |
| **Alt+Left** | Move back one word |
| **Alt+Right** | Move forward one word |
| **Ctrl+L** | Clear screen |
| **Ctrl+Z** | Send to background / undo |
| **Alt+Enter** | Insert newline (multi-line editing) |
| **Alt+E** | Open command in $EDITOR |
| **Alt+P** | Page through output (pipe to pager) |
| **Up/Down** | Cycle through history |

## 4. Vi Mode (normal mode)

You're in vi mode (set by omarchy's `init.fish`). Press **Escape** to enter normal mode from insert mode.

### Navigation

| Key | What it does |
|---|---|
| **h/l** | Move left/right |
| **w/W** | Forward word / WORD |
| **b/B** | Back word / WORD |
| **e/E** | End of word / WORD |
| **0** | Beginning of line |
| **$** | End of line (or last arg of prev command, see below) |
| **^** | First non-blank character |
| **f**{char} | Jump to next {char} |
| **F**{char} | Jump to prev {char} |
| **t**{char} / **T**{char} | Jump to before/after {char} |
| **;** / **,** | Repeat / reverse last f/F/t/T |

### Editing (from normal mode)

| Key | What it does |
|---|---|
| **i** | Enter insert mode at cursor |
| **I** | Insert at beginning of line |
| **a** | Insert after cursor |
| **A** | Insert at end of line |
| **o** | Open line below |
| **O** | Open line above |
| **x** | Delete char under cursor |
| **X** | Delete char before cursor |
| **r**{char} | Replace char under cursor |
| **dd** | Delete entire line |
| **D** | Delete to end of line |
| **cc** | Change entire line |
| **C** | Change to end of line |
| **dw** | Delete word |
| **cw** | Change word |
| **yy** | Yank (copy) entire line |
| **yw** | Yank word |
| **p** | Paste after cursor |
| **P** | Paste before cursor |
| **u** | Undo |
| **/** | Search forward in history |

### Visual mode

| Key | What it does |
|---|---|
| **v** | Enter visual character mode |
| **V** | Enter visual line mode |
| **d** / **x** | Delete selection |
| **y** | Yank selection |

## 5. Bang-Bang Shortcuts (CachyOS)

| Shortcut | What it does |
|---|---|
| **!!** | Expand to previous command (type `!!` then space/enter) |
| **!$** | Expand to last argument of previous command |

## 6. Autopair (automatic bracket/quote pairing)

Installed by omarchy-fish. When you type an opening bracket or quote, the closing one is auto-inserted:

| Type | Auto-pairs |
|---|---|
| `(` | → `()` |
| `[` | → `[]` |
| `{` | → `{}` |
| `"` | → `""` |
| `'` | → `''` |
| **Backspace** on empty pair | Deletes both |
| Type closing char | Skips over it if already present |

## 7. Omarchy Vendor Functions (short command aliases)

These aren't keybindings but short commands that save keystrokes:

| Command | Expands to |
|---|---|
| `g` | `git` |
| `d` | `docker` |
| `n` | `nvim` (opens `.` if no args) |
| `c` | `opencode` |
| `r` | `rails` |
| `ff` | `fzf --preview 'bat --style=numbers --color=always {}'` |
| `ls` | `eza -lh --group-directories-first --icons=auto` |
| `lsa` | `ls -a` (eza with hidden files) |
| `lt` | `eza --tree --level=2 --long --icons --git` |
| `lta` | `lt -a` |
| `cd` / `zd` | zoxide-backed cd (learns your frequent dirs, fuzzy matches) |
| `gcm "msg"` | `git commit -m "msg"` |
| `gcam "msg"` | `git commit -a -m "msg"` |
| `gcad` | `git commit -a --amend` |
| `open` | `xdg-open` (open files with default app) |
| `..` | `cd ..` |
| `...` | `cd ../..` (up to 6 levels) |

## 8. Your Abbreviations (conf.d/abbr.fish)

Type the abbreviation and it expands on Space/Enter. 96+ defined, highlights:

| Abbr | Expands to | Category |
|---|---|---|
| `v` | `nvim` | Editor |
| `se` | `sudoedit` | Editor |
| `gg` | `lazygit` | Git |
| `cm` | `chezmoi` | Dotfiles |
| `cl` | `claude` | AI |
| `clc` | `claude -c` | AI |
| `l` | `eza -lh --icons --git` | Files |
| `sc` | `systemctl` | Systemd |
| `scs` | `systemctl status` | Systemd |
| `scr` | `sudo systemctl restart` | Systemd |
| `jr` | `journalctl` | Logs |
| `jrf` | `journalctl -f` | Logs |
| `dps` | `docker ps` | Docker |
| `dcu` | `docker compose up -d` | Compose |
| `dcd` | `docker compose down` | Compose |
| `dcl` | `docker compose logs -f` | Compose |
| `nr` | `npm run` | Node |
| `nrd` | `npm run dev` | Node |
| `pg` | `pgcli -h localhost ...` | Database |
| `ports` | `ss -tulnp` | Network |
| `ipa` | `ip -c addr` | Network |
| `dk` | `dysk` | Disk |
| `kssh` | `kitty +kitten ssh` | Kitty |
| `kicat` | `kitty +kitten icat` | Kitty |
| `kdiff` | `kitty +kitten diff` | Kitty |

Full list: `abbr --show` or see `~/.config/fish/conf.d/abbr.fish`

## 9. Custom Functions (invoke by name)

| Command | What it does |
|---|---|
| `cme <file>` | Edit or add dotfile with chezmoi (fuzzy basename match) |
| `cmf <pattern>` | Grep across all chezmoi-managed files with fzf |
| `mc <dir>` | mkdir + cd in one step |
| `y` | Launch yazi file manager, cd to selected dir on exit |
| `abbr-edit` | Edit abbreviations file, auto-sources + chezmoi adds |
| `load-api-keys` | Load API keys from 1Password |

## 10. Notification (done plugin)

Long-running commands (>10s) trigger a desktop notification when they finish. No keybinding needed — it's automatic.
