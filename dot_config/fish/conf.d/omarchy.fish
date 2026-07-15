# Omarchy CLI on PATH (omarchy-fish's vendor files don't do this)
if test -d ~/.local/share/omarchy/bin
    set -gx OMARCHY_PATH ~/.local/share/omarchy
    fish_add_path -g ~/.local/share/omarchy/bin
    # keep ~/.local/bin ahead of omarchy/bin so local shadows win
    # (omarchy-launch-wifi -> wlctl/NM, 2026-07-15)
    fish_add_path -gm ~/.local/bin
end
