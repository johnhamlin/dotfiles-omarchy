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
# Full diagnosis: ~/notes/fontconfig-2.18-segoe-adwaita-2026-06-11.md
set -eu
gsettings set org.gnome.desktop.interface font-name 'Inter 10'
