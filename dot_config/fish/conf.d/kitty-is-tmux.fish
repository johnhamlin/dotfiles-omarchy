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
#
# The var is per-kitty-window and STICKY — nothing clears it when the tmux
# session exits. Left alone, the window stays in "tmux mode" forever and
# ctrl+hjkl stops navigating kitty splits there (observed 2026-08-06). So the
# outer, non-tmux fish clears it after every command: by the time control
# returns to that prompt, any tmux client launched from it has exited or
# detached, and this window is no longer showing tmux either way.
#
# `wkt` does the same set/clear pairing inline for the work-laptop session
# (fish/functions/wkt.fish) — it emits the signal locally rather than through
# the ssh chain, so a window showing IS_TMUX may be a live `wkt`, not a local
# session. See ~/notes/tmux-desktop-setup-2026-08-06.md.

if status is-interactive
    if set -q TMUX
        printf '\ePtmux;\e\e]1337;SetUserVar=IS_TMUX=MQo\a\e\\'
    else
        function __kitty_clear_is_tmux --on-event fish_postexec \
            --description 'Clear a stale IS_TMUX kitty user var after a tmux session exits'
            # Re-check rather than trusting the startup-time branch: a shell
            # that began outside tmux can still end up inside one.
            set -q TMUX; and return
            # Empty value deletes the var (same sequence as wkt.fish).
            printf '\e]1337;SetUserVar=IS_TMUX\a'
        end
    end
end
