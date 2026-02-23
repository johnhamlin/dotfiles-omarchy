function cme --description "Edit or add dotfiles with chezmoi"
    if test (count $argv) -eq 0
        echo "Usage: cme <target-file>" >&2
        echo "  Edit if managed by chezmoi, or create and add if not" >&2
        return 1
    end

    set -l target $argv[1]

    # If target doesn't look like a path, search managed files by name
    if not string match -qr '[/~]' $target
        set -l matches (chezmoi managed --include=files | grep -E "(^|/)$target\$")
        switch (count $matches)
            case 0
                # No match - fall through to create new file
            case 1
                set target ~/$matches[1]
            case '*'
                echo "Multiple matches for '$target':" >&2
                printf "  ~/%s\n" $matches >&2
                return 1
        end
    end

    if chezmoi source-path $target &>/dev/null
        chezmoi edit --apply $target
    else
        mkdir -p (dirname $target)
        nvim $target
        if test -f $target
            chezmoi add $target
            and echo "Added $target to chezmoi"
        end
    end
end
