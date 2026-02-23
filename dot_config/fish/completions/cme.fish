# Only complete first argument
complete -c cme -n "test (count (commandline -opc)) -ge 2" -f

# Basenames for quick fuzzy-ish access
complete -c cme -n "test (count (commandline -opc)) -lt 2" \
    -f -a "(chezmoi managed --include=files | xargs -n1 basename | sort -u)" \
    -d managed

# Full paths when you're being explicit
complete -c cme -n "test (count (commandline -opc)) -lt 2" \
    -f -a "(chezmoi managed --include=files | sed 's|^|~/|')" \
    -d managed

# Regular file completion for new files
complete -c cme -n "test (count (commandline -opc)) -lt 2" -F
