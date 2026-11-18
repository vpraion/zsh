# ==============================================================================
# Auto-fetch Git repositories in background with a 15-minute cooldown
# ==============================================================================

# Load built-in Zsh modules for zero-overhead timestamp and stat inspection
zmodload -F zsh/stat b:zstat 2>/dev/null
zmodload zsh/datetime 2>/dev/null

_git_auto_fetch() {
    # Check if we are inside a Git working tree
    local git_dir
    git_dir=$(git rev-parse --git-dir 2>/dev/null) || return 0

    local fetch_head="$git_dir/FETCH_HEAD"
    local last_fetch=0

    # Retrieve last fetch timestamp via zstat (or fallback to stat)
    if [[ -f "$fetch_head" ]]; then
        last_fetch=$(zstat +mtime "$fetch_head" 2>/dev/null)
        if [[ -z "$last_fetch" ]]; then
            if [[ "$OSTYPE" == darwin* ]]; then
                last_fetch=$(stat -f "%m" "$fetch_head" 2>/dev/null || echo 0)
            else
                last_fetch=$(stat -c "%Y" "$fetch_head" 2>/dev/null || echo 0)
            fi
        fi
    fi

    # 15 minutes cooldown (900 seconds)
    local interval=900
    local now=${EPOCHSECONDS:-$(date +%s)}

    if (( now - last_fetch <= interval )); then
        return 0
    fi

    # Only fetch if at least one remote is configured
    git remote 2>/dev/null | grep -q . || return 0

    # Touch FETCH_HEAD immediately to debounce and prevent duplicate concurrent fetches
    touch "$fetch_head" 2>/dev/null

    # Run fetch silently, non-interactively (no terminal prompts), and detached in background
    ( env GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o BatchMode=yes" \
        git fetch --quiet --no-tags --recurse-submodules=no 2>/dev/null &! )
}

# Run on directory change (cd) and before prompt rendering
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _git_auto_fetch
add-zsh-hook precmd _git_auto_fetch
