source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # smth smth
end

theme_tokyonight night

# Use nvim to read man pages
set -gx MANPAGER "nvim +Man!"

# Bring back history bindings
bind -M insert \cp history-prefix-search-backward
bind -M insert \cn history-prefix-search-forward
bind \cp history-prefix-search-backward
bind \cn history-prefix-search-forward

# Ctrl+. to accept next word of autosuggestion (requires kitty keybind)
bind -M insert \e\[46\;5u forward-word

# Re-enable fzf process search (omarchy disables it, Ctrl+Alt+P conflicts with Fcitx5 preedit)
fzf_configure_bindings --processes=\e\ck

# Disable flow control so Ctrl+S works, then bind to sudo toggle
stty -ixon 2>/dev/null
bind -M insert \cs __fish_prepend_sudo

# Load API keys from 1Password (call `load-api-keys` before using AI tools)
function load-api-keys --description "Load API keys from 1Password"
    # Adjust these paths to match your 1Password vault/item names
    set -gx ANTHROPIC_API_KEY (op read "op://Personal/Anthropic API Key/credential" 2>/dev/null)
    set -gx OPENAI_API_KEY (op read "op://Personal/OpenAI API Key/credential" 2>/dev/null)

    if test -n "$ANTHROPIC_API_KEY"
        echo "Loaded ANTHROPIC_API_KEY"
    else
        echo "Failed to load ANTHROPIC_API_KEY" >&2
    end
    if test -n "$OPENAI_API_KEY"
        echo "Loaded OPENAI_API_KEY"
    else
        echo "Failed to load OPENAI_API_KEY" >&2
    end
end
