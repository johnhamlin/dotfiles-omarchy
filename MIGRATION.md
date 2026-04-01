# New Machine Setup Checklist (ML4W)

## Prerequisites
- [ ] CachyOS installed
- [ ] ML4W (rolling) installed via `ml4w-hyprland-setup`
- [ ] SSH keys available (copy `~/.ssh/` from backup or re-export from 1Password)
- [ ] ML4W initial setup wizard completed (theme, wallpaper, waybar style)

## Core Setup

1. **Install chezmoi + git**
   ```bash
   sudo pacman -S chezmoi git
   ```

2. **Initialize dotfiles**
   ```bash
   chezmoi init johnhamlin/dotfiles-omarchy --branch ml4w
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
   - Write source lines into ML4W's `~/.config/hypr/conf/custom.conf` (bridge script)
   - Protect `~/.config/fish/` and `~/.config/kitty/` from ML4W updates
   - Deploy terminal configs (kitty custom.conf, alacritty, ghostty)
   - Deploy helper scripts to `~/.local/bin/`
   - Deploy nvim, fish, git, tmux, starship, lazygit configs

6. **Reload Hyprland to apply config**
   ```bash
   hyprctl reload
   ```

## Package Management

7. **Remove Omarchy packages** (if migrating from Omarchy):
   ```bash
   # These are no longer needed — ML4W or our config replaces them
   sudo pacman -Rns omarchy-fish omarchy-keyring omarchy-nvim omarchy-walker mako swaybg 2>/dev/null
   ```

8. **Install additional packages** our config needs (ML4W may already have some):
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
    #   Super+Comma      — notification panel (swaync)
    #   Volume keys      — should show swayosd on-screen display
    ```

12. **Configure monitors** — ML4W handles this via its settings app (`Super+Ctrl+P` → settings), or manually:
    ```bash
    hyprctl monitors                 # identify connected monitors
    # ML4W stores monitor config in ~/.config/hypr/conf/monitor.conf
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

## Laptop-Specific Setup

20. **NVIDIA power management** (ThinkPad P1 Gen4 or similar hybrid GPU laptops):
    ```bash
    # Set initial power mode
    power-mode status               # check current state
    power-mode balanced             # or: performance, battery
    # Requires reboot to fully apply (including BIOS GPU mode via ThinkLMI)
    ```

21. **Vivaldi browser wrappers** (if using Vivaldi with NVIDIA):
    ```bash
    # Create desktop files for GPU-specific browser launching
    # power-mode switches the default browser between these
    # See ~/.local/share/applications/vivaldi-{nvidia,intel}.desktop
    ```

22. **Verify laptop-specific features**:
    ```bash
    # Brightness keys should work via swayosd
    # Keyboard backlight keys should work
    # Touchpad gestures (3-finger horizontal = workspace switch)
    # power-brightness script adjusts screen brightness on AC/battery
    # hypridle: 2.5min lock on laptop vs 30min on desktop
    ```

## ML4W-Specific Notes

### What ML4W Manages (don't touch with chezmoi)
- `~/.config/hypr/` — Hyprland base config, monitor config, scripts
- `~/.config/waybar/` — waybar config, themes, toggle script
- `~/.config/rofi/` — app launcher, emoji picker, clipboard
- `~/.config/swaync/` — notification center
- `~/.config/hypr/hyprlock.conf` — lock screen (use ML4W themes)
- `~/.config/hypr/hypridle.conf` — idle behavior
- GTK/QT theming — handled by ML4W's material theme system

### What We Override (via custom.conf bridge)
- Appearance: 0 gaps, Tokyo Night borders, animations
- Keybindings: vim HJKL, app launchers, media keys with swayosd
- Window rules: 25+ app-specific rules
- Input: compose:caps, repeat rate, touchpad settings
- Env vars: NVIDIA, XCompose
- Autostart: fcitx5, swayosd, hyprsunset

### ML4W Features Preserved (relocated keys)
| Feature | New Key | Original ML4W Key |
|---------|---------|-------------------|
| Swap split | `Super+Ctrl+K` | `Super+K` |
| Show keybindings | `Super+Ctrl+Shift+K` | `Super+Ctrl+K` |
| Light/dark toggle | `Super+Ctrl+M` | `Super+Shift+M` |
| Game mode | `Super+Ctrl+G` | `Super+Alt+G` |
| Wallpaper selector | `Super+Ctrl+Shift+W` | `Super+Ctrl+W` |
| Waybar themes | `Super+Ctrl+Shift+T` | `Super+Ctrl+T` |
| Toggle animations | `Super+Ctrl+Shift+A` | `Super+Shift+A` |

### ML4W Features Kept on Original Keys
- `Super+Shift+Q` — kill process
- `Super+Shift+T` — float all windows
- `Super+Alt+T` — float + pin
- `Super+Ctrl+Return` — rofi launcher
- `Super+Ctrl+P` — power menu / ML4W settings
- `Super+Ctrl+S` — sidebar widget
- `Super+Ctrl+R` — reload config
- `Super+Ctrl+Down` — open empty workspace
- `Super+Ctrl+1-0` — move ALL windows to workspace
- `Ctrl+Tab` — window overview
- `Ctrl+Alt+T` — theme selector

### ML4W Updates
```bash
# After ML4W updates, our custom.conf may get overwritten.
# Re-apply to regenerate it:
chezmoi apply

# If ML4W changes break something:
hyprctl reload                    # check for errors
chezmoi diff                      # see what changed
```

## Architecture: Three-Layer Config

- **Layer 1 — ML4W base**: owns `~/.config/hypr/`, waybar, rofi, swaync, hyprlock, hypridle
- **Layer 2 — Our overrides**: `~/.config/hypr-custom/` managed by chezmoi (appearance, keybindings, window rules)
- **Layer 3 — The bridge**: `run_onchange_` script writes source lines into ML4W's `custom.conf`

ML4W's `hyprland.conf` sources `conf/custom.conf` LAST, so our overrides win.

## Items NOT Managed by chezmoi

| Item | Action |
|------|--------|
| `~/.ssh/` | Copy from encrypted backup or re-export from 1Password |
| `~/.gnupg/` | Copy keyring or re-import |
| `~/.config/gh/` | Run `gh auth login` |
| `~/.claude/` | Copy directory from old machine |
| `~/.XCompose` | Copy from backup (envs.conf points to it) |
| `~/.config/hypr/` | ML4W owns this — our overrides go in `hypr-custom/` |
| `~/.config/waybar/` | ML4W owns |
| `~/.config/rofi/` | ML4W owns |
| `~/.config/swaync/` | ML4W owns |
| `~/.config/power-profiles/` | Auto-generated by `power-mode` |
| `/etc/keyd/` | Stored in repo under `keyd/` — copy manually with `sudo` (see step 17) |

## Verification

```bash
# Config structure
chezmoi diff                                    # should show no diff after apply
chezmoi managed | wc -l                         # verify managed file count
chezmoi managed | grep hypr-custom              # should list ~11 override files
chezmoi managed | grep -c "\.config/hypr/"      # should be 0 (ML4W owns hypr/)
chezmoi execute-template '{{ .formFactor }}'    # should print "desktop" or "laptop"

# Bridge is working
cat ~/.config/hypr/conf/custom.conf             # should show source lines to hypr-custom/
hyprctl reload                                  # should apply with no errors

# Key features work
# Super+H/J/K/L  — vim focus
# Super+Space    — rofi launcher
# Super+Ctrl+E   — emoji picker
# Super+Ctrl+V   — clipboard manager
# Super+Comma    — swaync notification panel
# Volume keys    — swayosd on-screen display
# Super+Escape   — lock screen

# ML4W features still work
# Super+Ctrl+P   — power menu / settings
# Ctrl+Alt+T     — theme selector
# Ctrl+Tab       — window overview
```

## Troubleshooting

### hyprctl reload shows errors
```bash
# Check which file has the error:
hyprctl reload 2>&1
# Common cause: ML4W updated and changed a dispatcher name or option
# Fix: update the relevant file in hypr-custom/ and chezmoi apply
```

### custom.conf got overwritten by ML4W update
```bash
chezmoi apply   # regenerates custom.conf via run_onchange_ script
```

### ML4W settings app doesn't work
ML4W settings/themes should still work because we only override via custom.conf.
If theme switching breaks, check that our appearance.conf isn't conflicting with
ML4W's theme variables.

### swayosd not showing
```bash
pgrep swayosd-server          # should be running
systemctl --user status swayosd  # check systemd service
uwsm-app -- swayosd-server    # start manually
```

### Fish/kitty config overwritten by ML4W
```bash
ls ~/.config/fish/PROTECTED    # should exist
ls ~/.config/kitty/PROTECTED   # should exist
# If missing, re-run: chezmoi apply
# The run_once_ protection script creates these
```
