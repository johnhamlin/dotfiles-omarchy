# When fish starts inside tmux, tell the outer terminal (kitty) by setting
# the `IS_TMUX` kitty user var. The matching `--when-focus-on var:IS_TMUX`
# unmap rules in ~/.config/kitty/custom.conf then let ctrl+hjkl pass through
# to tmux instead of being eaten by kitty's `neighboring_window` bindings.
#
# Mirrors how smart-splits.nvim signals IS_NVIM (see
# smart-splits/lua/smart-splits/mux/kitty.lua). MQo is base64 of "1\n".
#
# Requires `allow-passthrough on` in ~/.config/tmux/tmux.conf (tmux 3.3+
# blocks DCS pass-through by default).
if status is-interactive; and set -q TMUX
    printf '\ePtmux;\e\e]1337;SetUserVar=IS_TMUX=MQo\a\e\\'
end
