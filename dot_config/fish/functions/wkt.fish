function wkt --description 'SSH into BT work laptop, attach tmux (grouped client by default) in WSL'
    # Named "wkt" (work-tmux) so it doesn't collide with the existing `wk`
    # abbreviation (= "ssh work").
    #
    # Usage:
    #   wkt          → grouped client off the shared `base` session.
    #                  Multiple wkt calls from different Kittys share the
    #                  same window list but each tracks its own current
    #                  window (move windows in one, the other stays put).
    #                  Pattern ported from the old MSYS2 tmux-setup.md.
    #   wkt notes    → plain attach-or-create session "notes" (ungrouped,
    #                  for genuinely separate contexts).
    #   wkt -l       → list existing tmux sessions on the remote
    #   wkt -k name  → kill the named session
    #
    # Architecture: ssh work-ps → pwsh → wsl.exe → tmux. wsl.exe processes are
    # parented to wslservice (NOT ssh-shellhost's Job Object), so the tmux
    # server survives SSH disconnect. Combined with `loginctl enable-linger
    # johnhamlin` inside the distro, sessions persist indefinitely until
    # `wsl --shutdown` or reboot. See ~/notes/work-laptop-wsl-tmux-setup.md.

    if test (count $argv) -eq 0
        # Grouped-client pattern via remote helper (avoids escape soup of
        # passing the multi-tmux-command pipeline through ssh→pwsh→wsl→bash).
        command ssh -t work-ps "wsl -d Ubuntu -e /home/johnhamlin/.local/bin/wkt-attach.sh"
        return
    end

    switch $argv[1]
        case '-l'
            command ssh work-ps "wsl -d Ubuntu -e tmux ls" 2>&1 | grep -v "post-quantum\|store now\|openssh.com\|wsl:\|networkingMode\|Error code"
        case '-k'
            if test (count $argv) -lt 2
                echo "wkt -k: needs a session name" >&2
                return 1
            end
            command ssh work-ps "wsl -d Ubuntu -e tmux kill-session -t $argv[2]" 2>&1 | grep -v "post-quantum\|store now\|openssh.com\|wsl:\|networkingMode\|Error code"
        case '*'
            # Named, ungrouped session — plain attach-or-create.
            command ssh -t work-ps "wsl -d Ubuntu -e tmux new-session -A -s $argv[1]"
    end
end
