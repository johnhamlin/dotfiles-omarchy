# New Machine Setup Checklist (Omarchy hybrid)

This machine runs **CachyOS + a pinned Omarchy 3.8.3 hybrid**, NOT stock Omarchy
and NOT HyDE. Omarchy is a read-only *parts catalog* (a pinned git clone) that
chezmoi-managed configs source; Omarchy's own installer is never run. Full design
+ rationale: `~/notes/omarchy-migration-2026-07.md`. Machine branch = `omarchy`.

> The desktop was migrated HyDE → Omarchy on 2026-07-14. This checklist targets a
> **fresh CachyOS** machine (or reprovision). The old HyDE checklist is preserved
> on the `hyde` branch of this repo if you ever need it.

## Prerequisites
- [ ] CachyOS installed (base kept as-is: linux-cachyos kernel, nvidia-open, Limine+sbctl+snapper, ufw, docker, NetworkManager WiFi pinning)
- [ ] SSH keys available (copy `~/.ssh/` from backup or re-export from 1Password)
- [ ] `iommu=pt` on `/proc/cmdline` (WiFi collapses without it) — never `iommu=soft`

## Core Setup

1. **Install chezmoi + git**
   ```bash
   sudo pacman -S chezmoi git
   ```

2. **Initialize dotfiles on the `omarchy` branch**
   ```bash
   chezmoi init johnhamlin/dotfiles-omarchy --branch omarchy
   ```

3. **Configure machine identity** — edit `~/.config/chezmoi/chezmoi.toml`:
   ```toml
   [data]
       machine = "desktop-amd"       # e.g. "desktop-amd", "thinkpad-p1-gen4"
       formFactor = "desktop"        # "desktop" or "laptop"
       gpu = "nvidia"                # "nvidia", "amd", or "intel"

   [edit]
       command = "nvim"
   ```

4. **Clone the pinned Omarchy parts catalog** (chezmoi configs source it; do NOT
   run its installer):
   ```bash
   git clone --branch v3.8.3 --depth 1 https://github.com/basecamp/omarchy.git ~/.local/share/omarchy
   cat ~/.local/share/omarchy/version   # -> 3.8.3 (detached HEAD at the tag is intended)
   ```
   `omarchy-update` / `omarchy-migrate` / `install.sh` are **forbidden** — see the
   update policy in `~/notes/omarchy-migration-2026-07.md`.

5. **Append the `[omarchy]` pacman repo LAST** (so CachyOS/chaotic win every name
   collision), then install the package set:
   ```bash
   printf '\n[omarchy]\nSigLevel = Optional TrustAll\nServer = https://pkgs.omarchy.org/stable/$arch\n' | sudo tee -a /etc/pacman.conf
   sudo pacman -Sy
   sudo pacman -S --needed omarchy-keyring
   sudo pacman -S --needed \
     omarchy-walker mako swaybg polkit-gnome hyprland-preview-share-picker \
     xdg-terminal-exec gnome-keyring gnome-themes-extra yaru-icon-theme \
     woff2-font-awesome ttf-jetbrains-mono-nerd inter-font omarchy-fish \
     wiremix impala bluetui gnome-calculator libqalculate \
     nautilus-python sushi gvfs-nfs gvfs-smb tesseract tesseract-data-eng \
     evince imv mpv python-terminaltexteffects yay uwsm kitty
   # AUR/full-experience extras (paru/yay), review first:
   #   spotify obs-studio cliamp obsidian typora gnome-disk-utility bolt tobi-try
   #   dust whois socat xmlstarlet aether
   ```

6. **Preview and apply dotfiles**
   ```bash
   chezmoi diff                     # review; hypr/, hypr-custom/, uwsm, kitty, fontconfig, fish, bashrc
   chezmoi apply ~/.config/hypr ~/.config/hypr-custom ~/.config/uwsm ~/.config/kitty \
                 ~/.config/fontconfig ~/.config/fish ~/.config/xdg-terminals.list \
                 ~/.bashrc ~/.local/bin
   ```
   This deploys `~/.config/hypr/hyprland.conf` (the top-level source chain that
   sources Omarchy defaults from `~/.local/share/omarchy` + John's `hypr-custom/`
   binds), `hypridle.conf`, `monitors.conf`, our `uwsm/env` (OMARCHY_PATH + mise
   shims), `kitty.conf`, `fontconfig/fonts.conf` (Inter), fish/bashrc, helper
   scripts.

7. **Walker/elephant wiring + swayosd** (user-level scripts from the clone — inspect first):
   ```bash
   O=~/.local/share/omarchy
   bash $O/install/config/walker-elephant.sh      # autostart + elephant menu symlinks (verify: only $HOME cp/ln/mkdir)
   systemctl --user daemon-reload
   systemctl --user enable --now swayosd-server.service
   ```

8. **Theme init** (populates `~/.config/omarchy/current/theme/*`, which hyprland.conf sources):
   ```bash
   export OMARCHY_PATH=~/.local/share/omarchy PATH=~/.local/share/omarchy/bin:$PATH
   mkdir -p ~/.local/state/omarchy/toggles/hypr
   cp $OMARCHY_PATH/default/hypr/toggles/flags.conf ~/.local/state/omarchy/toggles/hypr/
   omarchy-theme-set tokyo-night
   test -f ~/.config/omarchy/current/theme/hyprland.conf && echo THEME-OK
   ```

9. **gsettings (theme + durable Inter font)**:
   ```bash
   gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
   gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
   gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"
   gsettings set org.gnome.desktop.interface font-name 'Inter 10'
   ```
   Omarchy never writes `font-name`, so this is durable (unlike under HyDE). Do
   NOT set Cantarell — Chromium can't load its CFF2 VF. See `~/notes/font-breakage-2026-06-11.md`.

## Login (SDDM autologin) — SUDO

10. **Run Omarchy's SDDM + keyring scripts** (inspect first; they configure the
    Wayland greeter, autologin, session desktop, PAM keyring strip):
    ```bash
    O=~/.local/share/omarchy
    export OMARCHY_PATH=$O PATH=$O/bin:$PATH
    bash $O/install/login/sddm.sh
    bash $O/install/login/default-keyring.sh
    # Add monitor rotation to the greeter (use /usr/bin/grep to dodge the RTK tee-pipe bug):
    /usr/bin/grep '^monitor' ~/.config/hypr/monitors.conf | sudo tee -a /usr/share/sddm/hyprland.conf
    ```

11. **Login shell → bash** (Omarchy requirement; `~/.bashrc` exec-hands-off to fish):
    ```bash
    chsh -s /bin/bash
    ```

12. **keyd** (keyboard remapping):
    ```bash
    sudo pacman -S --needed keyd
    sudo cp ~/.local/share/chezmoi/keyd/common ~/.local/share/chezmoi/keyd/hhkb.conf /etc/keyd/
    sudo systemctl enable --now keyd && sudo keyd reload
    ```

13. **Runtimes, GitHub, 1Password, Claude, GPG**:
    ```bash
    mise install
    gh auth login
    # Install 1Password desktop app, enable SSH agent; verify: ssh-add -l
    cp -r /path/to/backup/.claude ~/          # Claude Code config
    gpg --import /path/to/backup/private-key.asc   # if needed
    ```

14. **Webapps + mimetypes** (recreate via `omarchy-webapp-install`; imv/mpv defaults):
    ```bash
    bash ~/.local/share/omarchy/install/config/mimetypes.sh   # inspect first
    # omarchy-webapp-install per app (chatgpt/claude/gmail/teams/work-email/youtube/youtube-music)
    # teams keeps --ozone-platform=x11 in its .desktop Exec
    ```

Then reboot into the SDDM autologin session.

## Config ownership (mirror of ~/notes/CLAUDE.md)

- **chezmoi-owned** (edit source, apply, commit to branch `omarchy`):
  `~/.config/hypr/hyprland.conf`, `monitors.conf`, `hypridle.conf`, all
  `~/.config/hypr-custom/*`, `kitty/kitty.conf` + `custom.conf`,
  `fontconfig/fonts.conf`, `uwsm/{env,default}`, `~/.bashrc`, `fish/conf.d/*`,
  `xdg-terminals.list`, `walker/config.toml`, `~/.local/bin/*`.
- **Omarchy-owned — never edit**: `~/.local/share/omarchy` (pinned clone),
  `~/.config/omarchy/current/` (theme output, `omarchy-theme-set` regenerates),
  `~/.local/state/omarchy/` (toggle state).
- **Drift generators**: `omarchy-refresh-*` / `omarchy-theme-set` write into
  `~/.config/hypr/*` — run `chezmoi diff` after and reconcile deliberately.
- **Bindings**: Omarchy's default binding files are deliberately NOT sourced;
  John's keymap wins. Passthrough submap (SUPER+F12) must stay last in the chain.

## Items NOT Managed by chezmoi

| Item | Action |
|------|--------|
| `~/.ssh/` | Copy from encrypted backup or re-export from 1Password |
| `~/.gnupg/` | Copy keyring or re-import |
| `~/.config/gh/` | Run `gh auth login` |
| `~/.claude/` | Copy directory from old machine |
| `~/.local/share/omarchy` | Pinned v3.8.3 clone (step 4) — never via installer |
| `~/.config/omarchy/`, `~/.local/state/omarchy/` | Generated by `omarchy-theme-set` / toggles |
| `/etc/keyd/` | Stored in repo under `keyd/` — copy manually with `sudo` (step 12) |
| `/etc/sddm.conf.d/`, `/usr/share/sddm/hyprland.conf` | From Omarchy's login scripts (step 10) |

## Verification

```bash
chezmoi execute-template '{{ .formFactor }}'        # "desktop" or "laptop"
git -C ~/.local/share/chezmoi branch --show-current # "omarchy"
cat ~/.local/share/omarchy/version                  # 3.8.3
Hyprland --verify-config -c ~/.config/hypr/hyprland.conf   # no errors
grep -ci hyde ~/.config/hypr/hyprland.conf          # 0
gsettings get org.gnome.desktop.interface font-name # 'Inter 10'
hyprctl binds -j | jq length                        # ~157

# Key features:
# Super+Space    — walker launcher
# Super+C/V/X    — universal clipboard (sendshortcut)
# Super+Escape   — omarchy system menu
# Super+semicolon — mako dismiss
# Super+Ctrl+K   — keybind help
# Super+F12 x2   — passthrough submap in/out
# loginctl lock-session — hyprlock + screens off (~3s)
```

---

# WSL Setup Checklist

## Prerequisites
- [ ] Windows 11 with WSL2 enabled
- [ ] Ubuntu installed in WSL2 (`wsl --install -d Ubuntu`)
- [ ] SSH keys available (copy from Windows host or export from 1Password)
- [ ] JetBrainsMono Nerd Font installed on Windows (for Windows Terminal)

## Core Setup

1. **Install chezmoi + dependencies**
   ```bash
   sudo apt update && sudo apt install -y git fish tmux
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```

2. **Initialize dotfiles**
   ```bash
   chezmoi init johnhamlin/dotfiles-omarchy --branch wsl
   ```

3. **Configure machine identity** — edit `~/.config/chezmoi/chezmoi.toml`:
   ```toml
   [data]
       machine = "work-wsl"
       formFactor = "desktop"
       gpu = "none"
       gitEmail = "john@workdomain.com"

   [edit]
       command = "nvim"
   ```

4. **Preview and apply**
   ```bash
   chezmoi diff
   chezmoi apply
   ```

5. **Set fish as default shell**
   ```bash
   chsh -s /usr/bin/fish
   ```

6. **Install CLI tools**
   ```bash
   # mise (runtime manager)
   curl https://mise.jdx.dev/install.sh | sh
   mise install

   # starship prompt
   curl -sS https://starship.rs/install.sh | sh

   # Core tools
   sudo apt install -y fzf ripgrep bat zoxide gh neovim

   # eza (apt may not have it — use cargo or the eza deb repo)
   # https://github.com/eza-community/eza/blob/main/INSTALL.md

   # yazi (from GitHub releases or cargo)
   # https://yazi-rs.github.io/docs/installation

   # fisher (fish plugin manager) + fzf.fish
   fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
   fish -c "fisher install PatrickF1/fzf.fish"
   ```

7. **Authenticate GitHub CLI**
   ```bash
   gh auth login
   ```

8. **Install 1Password CLI** (optional, for `load-api-keys`):
   ```bash
   # https://developer.1password.com/docs/cli/get-started/#install
   ```

## WezTerm Configuration

Copy `wezterm.lua` (in repo root) to `~/.wezterm.lua` on Windows (`%USERPROFILE%\.wezterm.lua`):

```powershell
copy \\wsl$\Ubuntu\home\john\.local\share\chezmoi\wezterm.lua %USERPROFILE%\.wezterm.lua
```

This configures:
- **Default domain**: WSL:Ubuntu with auto-launch into tmux (`tmux new-session -A -s main`)
- **Font**: JetBrainsMono Nerd Font, size 9, 14px padding
- **Keybinding passthrough**: Unbinds `Ctrl+B` (tmux prefix), `Ctrl+H/J/K/L` (smart-splits), `Alt+H/L` (tab switch)
- **Copy/paste**: `Ctrl+Insert` copy, `Shift+Insert` paste (receives PowerToys-remapped Win+C/V)

## PowerToys Keyboard Manager (Win+C/V/X Copy/Paste)

Replicates the CachyOS Hyprland `Super+C/V/X` muscle memory on Windows.

1. **Install PowerToys** from the Microsoft Store or [GitHub releases](https://github.com/microsoft/PowerToys/releases)
2. Open PowerToys Settings > **Keyboard Manager** > **Remap a shortcut**
3. Add these remaps:

   | Original | Remapped to | Purpose |
   |----------|-------------|---------|
   | `Win + C` | `Ctrl + Insert` | Copy (terminal-safe, no SIGINT) |
   | `Win + V` | `Shift + Insert` | Paste (terminal-safe) |
   | `Win + X` | `Ctrl + X` | Cut |
   | `Win + Ctrl + V` | `Win + V` | Windows clipboard history (relocated) |

   Or copy `powertoys-keyboard-manager.json` to `%LOCALAPPDATA%\Microsoft\PowerToys\Keyboard Manager\default.json` and restart PowerToys.

**How it works**: PowerToys intercepts Win+C/V/X system-wide before Windows processes them, translates to Ctrl+Insert / Shift+Insert / Ctrl+X, then WezTerm handles those as copy/paste. This is the same flow as CachyOS where Hyprland's `sendshortcut` translates Super+C/V to Ctrl+Insert / Shift+Insert.

## Keybinding Cheat Sheet: CachyOS vs WSL

All splits and tabs are managed by tmux inside WezTerm.

| Action | CachyOS (Hyprland + Kitty) | WSL (PowerToys + WezTerm + tmux) |
|--------|---------------------------|----------------------------------|
| **Copy** | `Super+C` | `Win+C` (via PowerToys) |
| **Paste** | `Super+V` | `Win+V` (via PowerToys) |
| **Cut** | `Super+X` | `Win+X` (via PowerToys) |
| **Clipboard history** | `Super+Shift+V` | `Win+Ctrl+V` (relocated) |
| **Prefix key** | `Ctrl+A` (kitty) | `Ctrl+B` (tmux) |
| New tab | `Ctrl+A > c` | `Ctrl+B c` |
| Rename tab | `Ctrl+A > ,` | `Ctrl+B r` |
| Horizontal split | `Ctrl+A > s` | `Ctrl+B v` |
| Vertical split | `Ctrl+A > v` | `Ctrl+B h` |
| Zoom pane | `Ctrl+A > z` / `F1` | `Ctrl+B z` / `F1` |
| Close pane | `Ctrl+A > x` | `Ctrl+B x` |
| Close tab | `Ctrl+A > q` | `Ctrl+B x` (kill-window) |
| Jump to tab N | `Ctrl+A > 1-9` | `Ctrl+B 1-9` |
| Next/prev tab | `Alt+L` / `Alt+H` | `Alt+L` / `Alt+H` |
| Navigate splits | `Ctrl+H/J/K/L` | `Ctrl+H/J/K/L` (smart-splits) |
| Swap pane | `Ctrl+A > Shift+H/J/K/L` | `Ctrl+B Shift+H/J/K/L` |
| Cycle layout | `Ctrl+A > Space` | `Ctrl+B Space` |
| Detach session | -- | `Ctrl+B d` |
| Reattach session | -- | `tmux attach` |

## GlazeWM (Tiling Window Manager)

Replicates Hyprland's tiling WM behavior on Windows — `Super+H/J/K/L` focus navigation, workspaces, window movement.

1. **Install GlazeWM** from [GitHub releases](https://github.com/glzr-io/glazewm/releases) or `winget install glzr-io.glazewm`
2. **Config auto-deploys** via chezmoi to `%userprofile%\.glzr\glazewm\config.yaml` (on Windows only)
3. **Launch GlazeWM** — it runs as a tray app

### Hyprland → GlazeWM Binding Map

| Action | Hyprland (CachyOS) | GlazeWM (Windows) |
|--------|-------------------|-------------------|
| Focus left/down/up | `Super+H/J/K` | `Win+H/J/K` |
| Focus right | `Super+L` | **`Win+;`** (Win+L = Windows lock) |
| Move window | `Super+Shift+H/J/K/L` | `Win+Shift+H/J/K/L` |
| Switch workspace | `Super+1-9` | `Win+1-9` |
| Move to workspace | `Super+Shift+1-9` | `Win+Shift+1-9` |
| Close window | `Super+Q` | `Win+Q` |
| Fullscreen | `Super+F` | `Win+F` |
| Toggle floating | `Super+T` | `Win+T` |
| Next/prev workspace | `Super+Tab/Shift+Tab` | `Win+Tab/Shift+Tab` |
| Resize mode | `Super+[-/=]` | `Win+R` then H/J/K/L |
| Toggle split | `Super+Ctrl+J` | `Win+Ctrl+J` |
| Reload config | -- | `Win+Shift+R` |

**Note:** Arrow key fallbacks are configured for all focus/move directions. `Win+L` is hardcoded by Windows to lock the screen and cannot be remapped, so focus-right uses `Win+;` (semicolon, right of L on QWERTY).

## What You Get
- Fish shell with vim bindings, abbreviations, fzf, zoxide
- Neovim (LazyVim) with full plugin suite and OSC 52 clipboard
- Tmux with vim-aware pane switching (smart-splits.nvim)
- Starship prompt
- Git config with work email
- Mise for runtime management (Node, Go, Bun, Java)
- IdeaVim config (for JetBrains IDEs on Windows host)
- GlazeWM tiling window manager with Hyprland-matching keybindings
- PowerToys Win+C/V/X for terminal-safe copy/paste

## What Is Excluded (desktop-only)
Controlled by `.chezmoiignore` WSL detection — these files exist in the repo but are never deployed on WSL:
- Hyprland / Omarchy configs
- Kitty, Alacritty, Ghostty terminal configs
- Keyd keyboard remapping
- Desktop scripts (gaming-mode, lock-screen, power management, etc.)
- Vivaldi browser flags

## WSL-Specific Notes

### Abbreviation editing
On WSL, `abbr.fish` is a chezmoi template. The `abbr-edit` function uses `chezmoi add` which would strip template markers. For editing abbreviations, use `chezmoi edit ~/.config/fish/conf.d/abbr.fish` instead.

### Clipboard
- **Win+C / Win+V** for copy/paste everywhere (via PowerToys → Ctrl+Insert / Shift+Insert → WezTerm)
- **Neovim** uses OSC 52 for clipboard, which works in WezTerm. Yanks in nvim go to the Windows clipboard.
- **tmux** copy mode: `prefix [` to enter, `v` to select, `y` to yank (copies to system clipboard via `set -g set-clipboard on`)

### Tmux sessions persist across terminal closes
WezTerm auto-attaches to an existing tmux session (`tmux new-session -A -s main`), so closing and reopening the terminal reconnects to your running session.
