function abbr-edit
    set -l abbr_file ~/.config/fish/conf.d/abbr.fish
    if string match -q '*nvim*' $EDITOR
        nvim +"normal Goabbr -a -- " +startinsert! $abbr_file
    else
        $EDITOR $abbr_file
    end
    and source $abbr_file
    and chezmoi add $abbr_file
    and echo "Abbreviations reloaded"
end
