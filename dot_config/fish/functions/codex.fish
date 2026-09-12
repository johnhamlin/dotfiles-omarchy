# Share new interactive sessions with ChatGPT Remote.
# Explicit arguments retain native CLI behavior; use --remote unix:// to share them.
function codex --wraps codex --description 'Start Codex on the shared daemon by default'
    if test (count $argv) -eq 0
        command codex app-server daemon start >/dev/null
        or return $status
        command codex --remote unix://
    else
        command codex $argv
    end
end
