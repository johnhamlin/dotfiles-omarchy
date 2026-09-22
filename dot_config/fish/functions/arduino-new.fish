function arduino-new --description 'Create an Uno or Mega sketch and open it in Neovim'
    if contains -- --help $argv; or test (count $argv) -lt 1; or test (count $argv) -gt 2
        echo 'Usage: arduino-new NAME [uno|mega]'
        echo 'Creates ~/Arduino/NAME. Asks for the board when omitted.'
        return 1
    end
    if not string match -qr '^[A-Za-z_][A-Za-z0-9_]{0,62}$' -- $argv[1]
        echo 'Use a name up to 63 characters: letters, numbers, underscores; start with a letter or underscore.' >&2
        return 1
    end
    set -l project "$HOME/Arduino/$argv[1]"
    if test -e "$project"; or test -L "$project"
        echo "Already exists: $project (nothing changed)" >&2
        return 1
    end
    set -l board $argv[2]
    if test -z "$board"
        read -P 'Board: [1] Uno R3  [2] Mega 2560: ' board; or return 1
    end
    set -l fqbn
    switch "$board"
        case 1 uno
            set fqbn arduino:avr:uno
        case 2 mega
            set fqbn arduino:avr:mega:cpu=atmega2560
        case '*'
            echo 'Choose 1/uno or 2/mega.' >&2
            return 1
    end
    command arduino-cli sketch new "$project"; or return 1
    command arduino-cli board attach --fqbn "$fqbn" "$project"; or return 1
    cd -- "$project"; or return 1
    command nvim "$argv[1].ino"
end
