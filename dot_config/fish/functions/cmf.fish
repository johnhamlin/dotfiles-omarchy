function cmf --description "Search chezmoi-managed dotfiles"
    # Handle help flag
    if contains -- --help $argv; or contains -- -h $argv
        echo "Usage: cmf <pattern> [options...]"
        echo ""
        echo "Search content across chezmoi-managed dotfiles."
        echo "Select a result to open in your editor at that line."
        echo ""
        echo "Options are passed through to grep/ripgrep."
        echo ""
        echo "Examples:"
        echo "  cmf 'set -g'     Search for global variable settings"
        echo "  cmf -i todo      Case-insensitive search"
        echo "  cmf -w path      Match 'path' as whole word"
        echo ""
        echo "Dependencies:"
        echo "  Required: chezmoi, fzf"
        echo "  Optional: ripgrep (rg), bat"
        echo ""
        echo "Environment:"
        echo "  \$EDITOR    Editor to use (default: nvim, vim, vi)"
        return 0
    end

    # Check required dependencies
    if not command -q chezmoi
        echo "cmf: chezmoi is required but not installed" >&2
        return 1
    end

    if not command -q fzf
        echo "cmf: fzf is required but not installed" >&2
        echo "  Install: https://github.com/junegunn/fzf" >&2
        return 1
    end

    if test (count $argv) -eq 0
        echo "cmf: missing search pattern" >&2
        echo "Usage: cmf <pattern> [options...]" >&2
        echo "Try 'cmf --help' for more information." >&2
        return 1
    end

    # Build list of managed files with full paths
    set -l files (chezmoi managed --include=files 2>/dev/null | sed "s|^|$HOME/|")

    if test (count $files) -eq 0
        echo "cmf: no managed files found" >&2
        return 1
    end

    # Determine search tool
    set -l search_cmd
    if command -q rg
        set search_cmd rg --line-number --color=always
    else
        # GNU grep fallback (BSD grep doesn't support --color=always reliably)
        set search_cmd grep -n --color=always -r
    end

    # Determine preview command
    set -l preview_cmd
    if command -q bat
        set preview_cmd "bat --color=always --highlight-line {2} {1}"
    else
        set preview_cmd "head -n \$(({2} + 5)) {1} | tail -n 15"
    end

    # Determine editor
    set -l editor_cmd
    if test -n "$EDITOR"
        set editor_cmd $EDITOR
    else if command -q nvim
        set editor_cmd nvim
    else if command -q vim
        set editor_cmd vim
    else if command -q vi
        set editor_cmd vi
    else
        echo "cmf: no editor found. Set \$EDITOR or install nvim/vim" >&2
        return 1
    end

    # Search and select
    set -l selection
    $search_cmd $argv -- $files 2>/dev/null \
        | fzf --ansi --delimiter=: \
        --preview $preview_cmd \
        --preview-window='~3:+{2}-5' \
        --exit-0 \
        | read -l selection

    # Handle fzf exit states
    switch $status
        case 0
            # Selection made
        case 1
            # No matches found
            echo "cmf: no matches found for '$argv[1]'" >&2
            return 1
        case 130
            # User cancelled (Ctrl-C or Esc)
            return 0
        case '*'
            return 1
    end

    if test -z "$selection"
        return 0
    end

    # Parse selection and open in editor
    set -l parts (string split : $selection)
    set -l file $parts[1]
    set -l line $parts[2]

    # Validate before opening
    if not test -f $file
        echo "cmf: file no longer exists: $file" >&2
        return 1
    end

    # Open editor at line (syntax varies by editor)
    switch (basename $editor_cmd)
        case nvim vim vi nvim-qt gvim
            $editor_cmd +$line $file
        case code
            $editor_cmd --goto $file:$line
        case subl
            $editor_cmd $file:$line
        case nano
            $editor_cmd +$line $file
        case emacs emacsclient
            $editor_cmd +$line $file
        case hx helix
            $editor_cmd $file:$line
        case '*'
            # Best effort: try +line syntax
            $editor_cmd +$line $file
    end
end
