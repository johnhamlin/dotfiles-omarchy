#!/bin/bash

# Prevent ML4W updates from overwriting configs we fully own.
# ML4W checks for a PROTECTED file before overwriting.

set -euo pipefail

for dir in "$HOME/.config/fish" "$HOME/.config/kitty"; do
  if [[ -d "$dir" ]]; then
    touch "$dir/PROTECTED"
    echo "Protected: $dir"
  fi
done
