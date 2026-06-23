function wkz --description 'SSH into BT work laptop, attach (or create) a named zellij session'
    # Named "wkz" (work-zellij) to coexist with `wkt` (work-tmux) and the
    # `wk` abbreviation (= "ssh work" plain fish, no multiplexer).
    #
    # Usage:
    #   wkz          → attach to (or create) session "main"
    #   wkz notes    → attach to (or create) session "notes"
    #   wkz -l       → list existing zellij sessions on the remote
    #   wkz -k name  → kill the named session
    #
    # Why zellij over tmux: tmux on MSYS2 routes display refreshes through
    # the Cygwin pty layer + ConPTY (double-translation), which causes
    # visible per-line scrolling on output like `ls`. zellij is a native
    # Windows binary that talks ConPTY directly — much faster refresh.
    # See ~/notes/work-laptop-ssh-jh-nested.md for the full story.

    if test (count $argv) -eq 0
        set session main
    else if test "$argv[1]" = "-l"
        command ssh work-ps 'C:\Users\john.hamlin\scoop\apps\zellij\current\zellij.exe list-sessions 2>&1' 2>&1 | grep -v "post-quantum\|store now"
        return
    else if test "$argv[1]" = "-k"
        if test (count $argv) -lt 2
            echo "wkz -k: needs a session name" >&2
            return 1
        end
        command ssh work-ps "C:\\Users\\john.hamlin\\scoop\\apps\\zellij\\current\\zellij.exe kill-session '$argv[2]'" 2>&1 | grep -v "post-quantum\|store now"
        return
    else
        set session $argv[1]
    end

    command ssh -t work-ps "\"C:\\Users\\john.hamlin\\.ssh-inner\\zellij-launcher.cmd\" $session"
end
