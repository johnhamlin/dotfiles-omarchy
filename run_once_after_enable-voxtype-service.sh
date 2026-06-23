#!/usr/bin/env sh
# Enable and start the voxtype user service after chezmoi drops the unit.
# Idempotent — safe to re-run if the file hash changes.
set -eu

systemctl --user daemon-reload
systemctl --user enable --now voxtype.service
