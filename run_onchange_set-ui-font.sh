#!/usr/bin/env bash
# Desktop UI font = Inter.
#
# Why not the GNOME default (Cantarell): Cantarell ships as a CFF2 *variable*
# OTF (Cantarell-VF.otf). After the 2026-06-11 update (harfbuzz 14 / freetype /
# fontconfig 2.18), Chromium/Skia can no longer load it. Chromium maps the CSS
# `system-ui` keyword to the GTK default UI font, so `system-ui` failed and fell
# back to the GTK *monospace* font (CaskaydiaCove Nerd Font Mono) in EVERY
# Chromium/Electron app (Vivaldi, Chrome, Teams) — the whole UI rendered
# monospace. gsettings is the source Chromium reads. Inter is a TrueType-
# flavoured font Chromium loads fine.
#
# FALLBACK ONLY (2026-07-09): this script is NOT durable by itself — HyDE
# stamps font-name into dconf on every theme/wallbash apply and reverted it to
# Cantarell on 2026-06-25 (run_onchange only re-runs when this file changes).
# The real fix is `[hyprland] font = "Inter"` in dot_config/hyde/config.toml,
# which makes HyDE itself write Inter.
#
# Full diagnosis: ~/notes/font-breakage-2026-06-11.md
set -eu
gsettings set org.gnome.desktop.interface font-name 'Inter 10'
