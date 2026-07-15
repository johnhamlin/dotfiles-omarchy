#!/usr/bin/env bash
# Middle-click paste (primary selection) in GTK/Chromium apps.
#
# Chromium-family browsers (Vivaldi, Chrome) honor the GTK gsetting
# `gtk-enable-primary-paste`; with it false, middle-click paste silently does
# nothing in them while working everywhere else (kitty etc.). This machine had
# it false (2026-07-15 diagnosis). Omarchy's installer sets it true in
# install/first-run/gtk-primary-paste.sh — one of the first-run scripts the
# hybrid migration deliberately never ran (same gap class as the screensaver
# branding). Stamped here so it survives reinstalls/dconf resets.
#
# Diagnosis trail: ~/notes/omarchy-migration-2026-07.md (2026-07-15 section)
set -eu
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true
