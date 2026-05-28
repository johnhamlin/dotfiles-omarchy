function wkt --description 'SSH into BT work laptop, attach (or create) a named tmux session in WSL'
    # Named "wkt" (work-tmux) so it doesn't collide with the existing `wk`
    # abbreviation (= "ssh work"). Use `wk` for fish only, `wkt` for tmux.
    #
    # Usage:
    #   wkt          → attach to (or create) session "main"
    #   wkt notes    → attach to (or create) session "notes"
    #   wkt -l       → list existing tmux sessions on the remote
    #   wkt -k name  → kill the named session
    #
    # Architecture: ssh work-ps → pwsh → wsl.exe → tmux. wsl.exe processes are
    # parented to wslservice (NOT ssh-shellhost's Job Object), so the tmux
    # server survives SSH disconnect. Combined with `loginctl enable-linger
    # johnhamlin` inside the distro, sessions persist indefinitely until
    # `wsl --shutdown` or reboot. See ~/notes/work-laptop-wsl-tmux-setup.md.

    if test (count $argv) -eq 0
        set session main
    else if test "$argv[1]" = "-l"
        command ssh work-ps "wsl -d Ubuntu -e tmux ls" 2>&1 | grep -v "post-quantum\|store now\|openssh.com\|wsl:\|networkingMode\|Error code"
        return
    else if test "$argv[1]" = "-k"
        if test (count $argv) -lt 2
            echo "wkt -k: needs a session name" >&2
            return 1
        end
        command ssh work-ps "wsl -d Ubuntu -e tmux kill-session -t $argv[2]" 2>&1 | grep -v "post-quantum\|store now\|openssh.com\|wsl:\|networkingMode\|Error code"
        return
    else
        set session $argv[1]
    end

    command ssh -t work-ps "wsl -d Ubuntu -e tmux new-session -A -s $session"
end
