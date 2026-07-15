---
name: omarchy
description: >
  REQUIRED for desktop/DE customization on THIS machine (beast-cachy): Hyprland,
  window rules, keybindings, monitors, gaps, borders, opacity, waybar, walker,
  mako, terminal config, themes, wallpaper, night light, idle/lock behavior,
  screenshots, reminders, or any omarchy-* command. This is a CachyOS + pinned
  Omarchy 3.8.3 HYBRID — the stock Omarchy skill's advice is wrong here in
  load-bearing ways. Read this before editing anything under ~/.config/.
---

# Omarchy on beast-cachy (CachyOS hybrid) — adapted skill

**This is NOT a stock Omarchy machine.** It is CachyOS with Omarchy 3.8.3 as a
*pinned, never-updated* desktop layer, migrated from HyDE on 2026-07-14. The
upstream skill this file replaces assumes a stock install; following it here
breaks the machine's config management. Authoritative references:
`~/notes/omarchy-migration-2026-07.md`, `~/notes/CLAUDE.md` (ownership map).

## Rule 0 — chezmoi owns the config layer

The stock skill says "edit files in ~/.config/ directly." **On this machine
that is wrong for every file chezmoi manages.** Direct edits are drift that the
next `chezmoi apply` silently reverts.

**The only correct workflow for chezmoi-owned files:**

```bash
# 1. Edit the SOURCE (branch `omarchy`)
$EDITOR ~/.local/share/chezmoi/dot_config/hypr-custom/bindings/utilities.conf.tmpl
# 2. Apply with an EXPLICIT target (never bare `chezmoi apply`)
chezmoi apply ~/.config/hypr-custom
# 3. Reload + validate (Hyprland changes)
hyprctl reload && hyprctl configerrors
# 4. Commit to the chezmoi repo (branch `omarchy`; never merge into `hyde`)
git -C ~/.local/share/chezmoi add -A && git -C ~/.local/share/chezmoi commit
```

**chezmoi-owned** (edit source only): `~/.config/hypr/hyprland.conf`,
`monitors.conf`, `hypridle.conf`, all of `~/.config/hypr-custom/`,
`kitty/kitty.conf` + `custom.conf`, `fontconfig/fonts.conf`,
`uwsm/{env,default}`, `~/.bashrc`, `fish/conf.d/*`, `xdg-terminals.list`,
`walker/config.toml`, `~/.XCompose`, `~/.local/bin/*`,
`~/.claude/skills/omarchy/` (this file).

**Omarchy-owned, never edit** (reading is encouraged):
`~/.local/share/omarchy` (pinned v3.8.3 clone — parts catalog),
`~/.config/omarchy/current/` (theme output), `~/.local/state/omarchy/`
(toggle flags).

**Unmanaged user copies** (edit directly, no chezmoi): `~/.config/waybar/`,
`~/.config/swayosd/`, `~/.config/elephant/`, `~/.config/imv/`,
`~/.config/wiremix/`, `~/.config/omarchy/{themes,hooks}/`.

## Rule 1 — forbidden and caution commands

| Command | Status | Why |
|---|---|---|
| `omarchy update` / `omarchy-update` / `omarchy migrate` | **FORBIDDEN** | Pulls master + runs migrations that assume vanilla Arch; can re-attempt boot-chain/pacman steps that would brick this box (sbctl-enrolled Limine, cachyos repos, iommu=pt). Version bumps are a manual, reviewed procedure — see "Updating Omarchy" below. |
| `install.sh`, `boot.sh`, `install/preflight/*`, `install/login/limine-snapper.sh`, `plymouth.sh`, `hibernation.sh`, `docker.sh`, `firewall.sh`, `hardware/nvidia.sh` | **FORBIDDEN** | Each would damage the CachyOS base (details in the migration note). |
| `omarchy refresh <app>` / `omarchy reinstall` | **CAUTION** | They overwrite deployed configs from the clone. For chezmoi-owned files this creates drift; for stock-Omarchy files it may erase deliberate local choices. Get user confirmation, then run `chezmoi diff` afterward and reconcile deliberately (adopt or revert). |
| `omarchy theme set` / `omarchy-theme-set` | OK, but | It regenerates `~/.config/omarchy/current/` AND restarts components. Run `chezmoi diff` after — it has historically not touched chezmoi files, but it is classed as a drift generator. |
| `omarchy pkg add` / `omarchy install <pkg>` | Prefer `pacman`/`paru` directly | `omarchy pkg add` is `yay --noconfirm`. Fine for simple cases; for anything conflict-prone, do a `pacman -S --print` preflight first. `[omarchy]` repo is deliberately LAST (lowest priority). |
| `omarchy debug` | OK with flags | Always `omarchy debug --no-sudo --print` (avoids interactive sudo hang). |

## Updating Omarchy (the only sanctioned way)

```bash
git -C ~/.local/share/omarchy fetch --tags
git -C ~/.local/share/omarchy diff v3.8.3..<new-tag> -- migrations/   # review EVERY script
# apply wanted changes selectively by hand, then move the pin:
git -C ~/.local/share/omarchy checkout <new-tag>
```
Anything touching boot/pacman/NVIDIA/NetworkManager in a migration is skipped,
always. `iommu=pt` must be on `/proc/cmdline` at every checkpoint.

## Keybindings — this machine's architecture (differs from stock)

**Omarchy's default binding files are deliberately NEVER sourced.** John's
keymap is authoritative and lives in chezmoi at
`dot_config/hypr-custom/bindings/{tiling.conf,apps.conf,media.conf.tmpl,utilities.conf.tmpl}`
(deployed without `.tmpl`). Wanted Omarchy features are bound explicitly.

- The stock skill's "add `unbind` before rebinding" advice does NOT apply —
  Omarchy defaults aren't loaded, so there is nothing to unbind. Check
  collisions with `hyprctl binds -j` instead (duplicate key+mod combos STACK
  in Hyprland — both fire).
- The SUPER+F12 passthrough submap at the end of `utilities.conf.tmpl` must
  remain the LAST bind-defining content in the whole source chain.
- `bindd = MODS, KEY, Description, dispatcher, args` is the house format.
- View current map: `omarchy menu keybindings --print` or SUPER+CTRL+K.
- Notable non-stock choices: SUPER+SPACE walker, SUPER+SHIFT+SPACE and
  SUPER+SHIFT+ESCAPE → omarchy-menu, SUPER+ESCAPE → system menu,
  SUPER+CTRL+A/B/W/T → omarchy-launch-{audio,bluetooth,wifi,tui btop},
  Compose = **Right Alt** (CapsLock is keyd-owned: ctrl/esc overload),
  PRINT → hyprshot (deliberate; not the stock satty flow).

## Machine-specific policies (do not "fix" these toward stock)

- **All windows fully opaque** — `windowrule = opacity 1.0 1.0, match:tag
  default-opacity` in `hypr-custom/windowrules/base.conf` overrides Omarchy's
  0.97/0.9 default. Translucency reads as blurry text; John wants none. The
  stock transparency toggle is unbound on purpose.
- **Fonts**: UI font is **Inter** via `gsettings font-name` + chezmoi
  `fontconfig/fonts.conf` (system-ui/sans → Inter). NEVER Cantarell (CFF2 VF
  breaks Chromium system-ui — `font-breakage-2026-06-11.md`). Terminal font is
  JetBrainsMono Nerd Font 9.0. Avoid `omarchy font set` (would fight this).
- **Idle/lock**: no idle auto-lock, no suspend. Screensaver at 5 min, screens
  off (single-shot) at 15 min from last input. Lock routes
  `loginctl lock-session` → hypridle → `omarchy-system-lock` (stock path,
  validated on driver 610.x). If screens ever stay lit after lock, the
  HyDE-era 10×/300ms DPMS retry loop is the documented fallback — chezmoi
  commit `22e8f7f` of `dot_config/hypr/hypridle.conf`.
- **Suspend is hidden** from the system menu via the `suspend-off` toggle.
- **Monitors**: John edits layout with nwg-displays, which regenerates the
  deployed `monitors.conf` → shows up as chezmoi drift → ADOPT it
  (`chezmoi add ~/.config/hypr/monitors.conf`), don't revert.
- **follow_mouse = 1 stays** (focus-follows-cursor is load-bearing for John).
- **HyDE is installed but inert** until demolition (post 2026-07-22); ignore
  `~/.config/hypr/{userprefs,keybindings,windowrules,nvidia}.conf` leftovers.

## Restart/reload semantics (stock knowledge that IS true here)

- Hyprland: auto-reloads on save of DEPLOYED files, but the workflow above
  means you change source + apply; then `hyprctl reload` + `hyprctl configerrors`.
- Waybar / Walker / terminals do NOT auto-reload: `omarchy restart waybar`,
  `omarchy restart walker`, `omarchy restart terminal`.
- Window-rule syntax churns between Hyprland versions — fetch current syntax
  from the Hyprland wiki before writing new rules; validate with
  `hyprctl configerrors` until clean.

## Command discovery (stock, all safe)

```bash
omarchy commands            # every documented command + summary
omarchy <group> --help      # e.g. omarchy theme --help
omarchy commands --json     # machine-readable
cat $(which omarchy-theme-set)   # reading command source is encouraged
```

Useful groups: `theme`, `toggle` (nightlight/idle/screensaver/suspend),
`restart`, `launch`, `capture` (screenshots/recordings), `reminder`
(`omarchy reminder 15 "Pickup Jack"`), `menu`, `snapshot`.

## Themes & hooks (user-owned, stock patterns apply)

- `omarchy theme list | current | set <name>` ("Tokyo Night", not
  "tokyo-night"), `omarchy theme bg next`.
- Custom themes: real directories under `~/.config/omarchy/themes/<name>/`
  (copy a stock theme from the clone as a starting point).
- Hooks: `~/.config/omarchy/hooks/{theme-set,font-set,post-update}` — note
  `post-update` never fires here (updates are forbidden).
- After ANY theme operation, `chezmoi diff` (drift-generator rule).

## Environment quirks for agents on this machine

- Claude Code sessions: the RTK hook rewrites commands. Two traps:
  (1) bare `sudo <cmd>` becomes `sudo rtk <cmd>` and fails — use absolute
  paths (`sudo /usr/bin/tee`); (2) rtk's output filter can silently corrupt
  piped output (once rendered a real `diff` as "identical", once truncated a
  `grep | tee` write) — for verification-grade output use `rtk proxy <cmd>`.
- Claude Code cannot sudo interactively: ask John to run `sudo -v` first.
- Never run bare `chezmoi apply` in subagents (TTY prompt on unrelated drift);
  always target explicit paths.

## Decision framework

1. Stock omarchy command that only launches/toggles/lists? → use it.
2. Config edit? → Is the file chezmoi-owned (see Rule 0)? Edit SOURCE +
   targeted apply + commit. Otherwise edit deployed file directly.
3. Theme customization? → new dir under `~/.config/omarchy/themes/`.
4. Package install? → prefer explicit `pacman`/`paru` with preflight.
5. Anything touching update/refresh/reinstall? → user confirmation first,
   `chezmoi diff` after.
6. Unsure whether an omarchy command exists? → `omarchy commands`.

## Example requests (adjusted for this machine)

- "Change theme to catppuccin" → `omarchy theme set catppuccin`; then `chezmoi diff`.
- "Add a keybinding for SUPER+E" → check `hyprctl binds -j` for collisions,
  edit `~/.local/share/chezmoi/dot_config/hypr-custom/bindings/*.tmpl`,
  `chezmoi apply ~/.config/hypr-custom`, `hyprctl reload`, commit.
- "Configure my monitors" → prefer nwg-displays, then ADOPT the drift into chezmoi.
- "Make gaps smaller" → `hypr-custom/appearance.conf` via chezmoi (John's
  overrides win over Omarchy's looknfeel).
- "Reset waybar to defaults" → `omarchy refresh waybar` is safe (waybar is
  unmanaged) but confirm with the user first.
- "Update omarchy" → refuse the command; offer the manual pin-move procedure.
