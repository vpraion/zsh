# Interactive alias finder and helper (alias-helper)

alias-helper() {
    local aliases_file="${ZDOTDIR:-$HOME/.config/zsh}/aliases.zsh"

    if [[ ! -f "$aliases_file" ]]; then
        echo "Aliases file not found: $aliases_file" >&2
        return 1
    fi

    # Parse aliases and descriptions dynamically from aliases.zsh
    local selected
    selected=$(awk '
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*#/ {
            sub(/^[[:space:]]*#[[:space:]]*/, "")
            last_comment = $0
            next
        }
        /^[[:space:]]*alias / {
            sub(/^[[:space:]]*alias[[:space:]]+/, "")
            eq_pos = index($0, "=")
            if (eq_pos > 0) {
                name = substr($0, 1, eq_pos - 1)
                cmd = substr($0, eq_pos + 1)
                gsub(/^'\''|'\''$/, "", cmd)
                gsub(/^"|"$/, "", cmd)
                desc = (last_comment != "" ? last_comment : "No description")
                printf "\033[1;36m%-14s\033[0m │ %-55s │ \033[33m%s\033[0m\n", name, desc, cmd
                last_comment = ""
            }
        }
    ' "$aliases_file" | fzf --ansi \
        --delimiter="│" \
        --with-nth="1,2" \
        --preview='echo -e "\033[1;34mCommand:\033[0m\n  {3}\n\n\033[1;33mDescription:\033[0m\n  {2}"' \
        --preview-window="down:3:wrap" \
        --prompt="Aliases > " \
        --header="Enter: insert into prompt | Esc: exit" \
        --query="$*")

    # If an entry was selected, put the alias name into the command line buffer
    if [[ -n "$selected" ]]; then
        local alias_name
        # Extract clean alias name (strip ANSI color escape codes and trailing whitespace)
        alias_name=$(echo "$selected" | awk -F'│' '{print $1}' | sed $'s/\x1b\\[[0-9;]*m//g' | tr -d '[:space:]')
        if [[ -n "$alias_name" ]]; then
            if [[ -n "$WIDGET" ]]; then
                LBUFFER+="$alias_name "
            else
                print -z "$alias_name "
            fi
        fi
    fi
}

# Alias for quick CLI access
alias al='alias-helper'

# ZLE widget for interactive alias helper
_alias_helper_widget() {
    alias-helper
    zle reset-prompt
}
zle -N _alias_helper_widget
