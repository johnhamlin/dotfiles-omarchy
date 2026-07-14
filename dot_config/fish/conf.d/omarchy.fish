# Omarchy CLI on PATH (omarchy-fish's vendor files don't do this)
if test -d ~/.local/share/omarchy/bin
    set -gx OMARCHY_PATH ~/.local/share/omarchy
    fish_add_path -g ~/.local/share/omarchy/bin
end
