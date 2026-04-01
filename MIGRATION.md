# New Machine Setup Checklist (HyDE)

## Prerequisites
- [ ] CachyOS installed
- [ ] HyDE installed via `~/HyDE/Scripts/install.sh`
- [ ] SSH keys available (copy `~/.ssh/` from backup or re-export from 1Password)
- [ ] HyDE initial setup wizard completed (theme, wallpaper, waybar style)

## Core Setup

1. **Install chezmoi + git**
   ```bash
   sudo pacman -S chezmoi git
   ```

2. **Initialize dotfiles**
   ```bash
   chezmoi init johnhamlin/dotfiles-omarchy --branch hyde
   ```

3. **Configure machine identity** — edit `~/.config/chezmoi/chezmoi.toml`:
   ```toml
   [data]
       machine = "desktop-name"      # e.g. "thinkpad-p1-gen4", "desktop-amd"
       formFactor = "desktop"        # "desktop" or "laptop"

   [edit]
       command = "nvim"
   ```

4. **Preview changes before applying**
   ```bash
   chezmoi diff                     # review what will change
   chezmoi managed | head -30       # verify managed file list looks right
   ```

5. **Apply dotfiles**
   ```bash
   chezmoi apply
   ```
   This will:
   - Deploy `~/.config/hypr-custom/` with all Hyprland overrides
   - Write source lines into HyDE's `~/.config/hypr/userprefs.conf` (bridge script)
   - Deploy terminal configs (kitty custom.conf, alacritty, ghostty)
   - Deploy helper scripts to `~/.local/bin/`
   - Deploy nvim, fish, git, tmux, starship configs

6. **Reload Hyprland to apply config**
   ```bash
   hyprctl reload
   ```

## Package Management

7. **Remove Omarchy packages** (if migrating from Omarchy):
   ```bash
   # These are no longer needed — HyDE or our config replaces them
   sudo pacman -Rns omarchy-fish omarchy-keyring omarchy-nvim omarchy-walker mako swaybg 2>/dev/null
   ```

8. **Install additional packages** our config needs (HyDE may already have some):
   ```bash
   # Required by our keybindings and scripts
   sudo pacman -S --needed \
     swayosd \
     fcitx5 fcitx5-gtk fcitx5-qt \
     hyprsunset \
     hyprshot \
     hyprpicker \
     cliphist \
     uwsm \
     jq \
     brightnessctl \
     gum \
     nautilus \
     pavucontrol \
     blueman \
     nm-connection-editor \
     btop \
     lazydocker \
     tmux \
     starship

   # AUR packages (install with paru/yay)
   # paru -S --needed 1password 1password-cli
   ```

9. **Install full package list** (optional — review first):
   ```bash
   # These lists may contain Omarchy-specific packages — review before installing
   cat ~/.local/share/chezmoi/packages-explicit.txt
   cat ~/.local/share/chezmoi/packages-aur.txt
   ```

10. **Install runtimes**
    ```bash
    mise install
    ```

## Post-Apply Configuration

11. **Verify Hyprland config**
    ```bash
    hyprctl reload                   # should apply with no errors
    # Test these keybindings:
    #   Super+H/J/K/L    — vim focus movement
    #   Super+Space      — rofi app launcher
    #   Super+Return     — terminal
    #   Super+Shift+B    — browser
    #   Super+Q          — close window
    #   Super+S          — scratchpad
    #   Super+Tab        — next workspace
    #   Super+Comma      — close notification (dunst)
    #   Volume keys      — should show swayosd on-screen display
    ```

12. **Configure monitors** — HyDE handles this via its settings tools, or manually:
    ```bash
    hyprctl monitors                 # identify connected monitors
    # HyDE stores monitor config in its own config chain
    ```

13. **Start swayosd daemon** (should auto-start, verify):
    ```bash
    # If volume/brightness OSD doesn't appear, check:
    pgrep swayosd-server || uwsm-app -- swayosd-server
    # Our autostart.conf handles this, but verify after first boot
    ```

14. **Authenticate GitHub CLI**
    ```bash
    gh auth login
    ```

15. **Copy Claude Code config**
    ```bash
    # From backup or old machine:
    cp -r /path/to/backup/.claude ~/
    ```

16. **Configure 1Password + SSH agent**
    - Install 1Password desktop app
    - Enable SSH agent in 1Password settings
    - Verify: `ssh-add -l`

17. **Install keyd configs** (keyboard remapping):
    ```bash
    sudo pacman -S --needed keyd
    sudo systemctl enable --now keyd

    # Configs are stored in the chezmoi repo under keyd/
    sudo cp ~/.local/share/chezmoi/keyd/common /etc/keyd/
    sudo cp ~/.local/share/chezmoi/keyd/hhkb.conf /etc/keyd/

    # internal.conf has a laptop-specific device ID — skip on desktop
    # or update the [ids] section for your keyboard:
    #   sudo keyd -m   # to find device IDs
    #   Then edit /etc/keyd/internal.conf with the correct ID
    sudo keyd reload
    ```

18. **Import GPG keys** (if needed):
    ```bash
    gpg --import /path/to/backup/private-key.asc
    ```

19. **Set up XCompose** (if using compose key for special characters):
    ```bash
    # Our input.conf sets compose:caps (Caps Lock = Compose key)
    # Copy your XCompose file from backup:
    cp /path/to/backup/.XCompose ~/
    # envs.conf sets XCOMPOSEFILE=~/.XCompose
    ```

## Shell Setup

20. **Fish shell in kitty**: HyDE uses zsh as the login shell (required for HyDE's shell integration). Our `kitty/custom.conf` sets `shell /usr/bin/fish` so kitty launches fish as the interactive shell. No changes to the system login shell needed.

## Laptop-Specific Setup

21. **NVIDIA power management** (ThinkPad P1 Gen4 or similar hybrid GPU laptops):
    ```bash
    # Set initial power mode
    power-mode status               # check current state
    power-mode balanced             # or: performance, battery
    # Requires reboot to fully apply (including BIOS GPU mode via ThinkLMI)
    ```

22. **Vivaldi browser wrappers** (if using Vivaldi with NVIDIA):
    ```bash
    # Create desktop files for GPU-specific browser launching
    # power-mode switches the default browser between these
    # See ~/.local/share/applications/vivaldi-{nvidia,intel}.desktop
    ```

23. **Verify laptop-specific features**:
    ```bash
    # Brightness keys should work via swayosd
    # Keyboard backlight keys should work
    # Touchpad gestures (3-finger horizontal = workspace switch)
    # power-brightness script adjusts screen brightness on AC/battery
    # hypridle: 2.5min lock on laptop vs 30min on desktop
    ```

## HyDE-Specific Notes

### What HyDE Manages (don't touch with chezmoi)
- `~/.config/hypr/` — Hyprland base config, monitor config, scripts
- `~/.config/waybar/` — waybar config, themes, layouts
- `~/.config/rofi/` — app launcher, emoji picker, clipboard
- `~/.config/dunst/` — notification daemon
- `~/.config/hypr/hyprlock.conf` — lock screen (use HyDE themes)
- `~/.config/hypr/hypridle.conf` — idle behavior
- `~/.local/share/hyde/` — HyDE internal data
- GTK/QT theming — handled by HyDE's wallbash theme system

### What We Override (via userprefs.conf bridge)
- Appearance: 0 gaps, Tokyo Night borders, animations
- Keybindings: vim HJKL, app launchers, media keys with swayosd
- Window rules: 25+ app-specific rules
- Input: compose:caps, repeat rate, touchpad settings
- Env vars: NVIDIA, XCompose
- Autostart: fcitx5, swayosd, hyprsunset

### HyDE Features Preserved (relocated keys)
| Feature | New Key | Original HyDE Key |
|---------|---------|-------------------|
| Toggle split | `Super+Ctrl+J` | `Super+J` |
| Game mode | `Super+Ctrl+G` | `Super+Alt+G` |
| Wallpaper selector | `Super+Ctrl+Shift+W` | `Super+Shift+W` |
| Rofi selector | `Super+Ctrl+Shift+A` | `Super+Shift+A` |
| Select animations | `Super+Ctrl+Shift+Y` | `Super+Shift+Y` |
| Game launcher | `Super+Ctrl+Shift+G` | `Super+Shift+G` |

### HyDE Features Kept on Original Keys
- `Super+Delete` — kill session
- `Ctrl+Alt+Delete` — logout
- `Super+Shift+F` — toggle pin (NOTE: our apps.conf overrides this with file manager)
- `Super+Alt+T` — dropdown terminal
- `Ctrl+Shift+Escape` — system monitor
- `Super+Shift+E` — file finder
- `Super+/` — keybindings hint
- `Super+.` — glyph picker
- `Super+Shift+V` — clipboard extended (favorites, multi-select, image OCR)
- `Super+Ctrl+P` — freeze screenshot
- `Super+Alt+P` — print monitor
- `Super+Alt+Right/Left` — wallpaper cycle
- `Super+Alt+Up/Down` — waybar layout
- `Super+Shift+R` — wallbash reload
- `Super+Shift+T` — theme selector
- `Super+Shift+U` — hyprlock layout selector
- `Super+Ctrl+Down/Right/Left` — workspace navigation
- `Super+Ctrl+Alt+Right/Left` — move to relative workspace
- `Super+Ctrl+M` — mute active window
- `F10/F11/F12` — mute/volume
- `Super+Z` — mouse move alt
- `Super+Shift+Ctrl+Arrow` — move window
- `Shift+F11` — fullscreen
- `Alt_R+Control_R` — waybar toggle

### HyDE `hyde-shell` Commands Reference
| Command | What it does |
|---------|-------------|
| `hyde-shell rofilaunch d` | App launcher (rofi drun) |
| `hyde-shell rofilaunch s` | Rofi selector |
| `hyde-shell rofilaunch g` | Game launcher |
| `hyde-shell emoji-picker` | Emoji picker |
| `hyde-shell cliphist -c` | Clipboard history |
| `hyde-shell waybar --hide` | Toggle waybar |
| `hyde-shell gamemode` | Toggle game mode |
| `hyde-shell wallpaper` | Wallpaper selector |
| `hyde-shell animations` | Animation selector |

### Dunst Notification Commands
| Binding | Command | Action |
|---------|---------|--------|
| `Super+Comma` | `dunstctl close` | Close top notification |
| `Super+Shift+Comma` | `dunstctl close-all` | Dismiss all |
| `Super+Ctrl+Comma` | `dunstctl set-paused toggle` | Toggle DND |
| `Super+Alt+Comma` | `dunstctl history-pop` | Show last notification |

### HyDE Updates
```bash
# After HyDE updates, our userprefs.conf may get overwritten.
# Re-apply to regenerate it:
chezmoi apply

# If HyDE changes break something:
hyprctl reload                    # check for errors
chezmoi diff                      # see what changed
```

## Architecture: Three-Layer Config

- **Layer 1 — HyDE base**: owns `~/.config/hypr/`, waybar, rofi, dunst, hyprlock, hypridle
- **Layer 2 — Our overrides**: `~/.config/hypr-custom/` managed by chezmoi (appearance, keybindings, window rules)
- **Layer 3 — The bridge**: `run_onchange_` script writes source lines into HyDE's `userprefs.conf`

HyDE sources `userprefs.conf` for user overrides, so our overrides win.

## Items NOT Managed by chezmoi

| Item | Action |
|------|--------|
| `~/.ssh/` | Copy from encrypted backup or re-export from 1Password |
| `~/.gnupg/` | Copy keyring or re-import |
| `~/.config/gh/` | Run `gh auth login` |
| `~/.claude/` | Copy directory from old machine |
| `~/.XCompose` | Copy from backup (envs.conf points to it) |
| `~/.config/hypr/` | HyDE owns this — our overrides go in `hypr-custom/` |
| `~/.config/waybar/` | HyDE owns |
| `~/.config/rofi/` | HyDE owns |
| `~/.config/dunst/` | HyDE owns |
| `~/.local/share/hyde/` | HyDE internal data |
| `~/.config/power-profiles/` | Auto-generated by `power-mode` |
| `/etc/keyd/` | Stored in repo under `keyd/` — copy manually with `sudo` (see step 17) |

## Verification

```bash
# Config structure
chezmoi diff                                    # should show no diff after apply
chezmoi managed | wc -l                         # verify managed file count
chezmoi managed | grep hypr-custom              # should list ~11 override files
chezmoi managed | grep -c "\.config/hypr/"      # should be 0 (HyDE owns hypr/)
chezmoi execute-template '{{ .formFactor }}'    # should print "desktop" or "laptop"

# Bridge is working
cat ~/.config/hypr/userprefs.conf               # should show source lines to hypr-custom/
hyprctl reload                                  # should apply with no errors

# Key features work
# Super+H/J/K/L  — vim focus
# Super+Space    — rofi launcher
# Super+Ctrl+E   — emoji picker
# Super+Ctrl+V   — clipboard manager
# Super+Comma    — close notification (dunst)
# Volume keys    — swayosd on-screen display
# Super+Escape   — lock screen

# HyDE features still work
# Super+Shift+T  — theme selector
# Super+Alt+Right/Left — wallpaper cycle
# Super+Alt+Up/Down — waybar layouts
# Super+Shift+R  — wallbash reload
# Super+/        — keybindings hint
```

## Troubleshooting

### hyprctl reload shows errors
```bash
# Check which file has the error:
hyprctl reload 2>&1
# Common cause: HyDE updated and changed a dispatcher name or option
# Fix: update the relevant file in hypr-custom/ and chezmoi apply
```

### userprefs.conf got overwritten by HyDE update
```bash
chezmoi apply   # regenerates userprefs.conf via run_onchange_ script
```

### HyDE theme/wallpaper selector doesn't work
HyDE themes should still work because we only override via userprefs.conf.
If theme switching breaks, check that our appearance.conf isn't conflicting with
HyDE's wallbash variables.

### swayosd not showing
```bash
pgrep swayosd-server          # should be running
systemctl --user status swayosd  # check systemd service
uwsm-app -- swayosd-server    # start manually
```

### Fish shell not loading in kitty
```bash
# Verify kitty custom.conf has: shell /usr/bin/fish
cat ~/.config/kitty/custom.conf | grep shell
# HyDE uses zsh as login shell — fish is only for kitty interactive use
```
