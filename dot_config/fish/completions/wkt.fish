# Fish completions for the work-laptop tmux launcher (~/.config/fish/functions/wkt.fish).
#
# When you type `wkt -<TAB>` fish surfaces the flags with their descriptions.
# When you type `wkt <TAB>` (or `wkt -k <TAB>`) fish lists existing remote
# tmux sessions, filtering out the internal `base` window-holder and the
# throwaway `client-*` grouped sessions so you can't accidentally attach
# to or kill the wrong thing.

function __wkt_sessions
    # Cache the SSH round-trip for 10s so back-to-back tabs are instant.
    set -l cache /tmp/wkt-sessions-cache
    set -l mtime (stat -c %Y $cache 2>/dev/null; or echo 0)
    if test (math (date +%s) - $mtime) -ge 10
        command ssh work-ps "wsl -d Ubuntu -e tmux ls" 2>/dev/null \
            | string replace -r ':.*' '' \
            | string match -rv '^base$|^client-' >$cache 2>/dev/null
    end
    cat $cache 2>/dev/null
end

complete -c wkt -f
complete -c wkt -s l -d 'List remote tmux sessions'
complete -c wkt -s k -d 'Kill a session by name' -x -a '(__wkt_sessions)'
complete -c wkt -a '(__wkt_sessions)' -d 'Attach (ungrouped) to existing session'
