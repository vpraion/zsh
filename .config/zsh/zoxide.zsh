# Interactive directory picker
_zoxide_fzf_widget() {
    local dir

    zle -I
    dir=$(zoxide query -l | fzf \
        --preview 'eza --tree --level=2 --color=always {}')

    [[ -n "$dir" ]] && cd -- "$dir"

    zle reset-prompt
}

zle -N _zoxide_fzf_widget
