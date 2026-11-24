#!/usr/bin/env zsh
# History

# Create dir if it doesn't exist
[[ -d "${XDG_STATE_HOME:-$HOME/.local/state}/zsh" ]] || mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"

HISTFILE="$XDG_STATE_HOME/zsh/history" # Defines where history file is located
HISTSIZE=100000 # Number of entries on RAM
SAVEHIST=100000 # Number of entries on Storage

setopt APPEND_HISTORY # Add dynamically entries to history file rather than waiting the tty to be exited
setopt SHARE_HISTORY # Shares and synchronizes history between multiple ttys
setopt HIST_IGNORE_DUPS # Don't record the command if it's the same as the previous one
setopt HIST_IGNORE_SPACE # Don't record commands starting with a space
setopt HIST_EXPIRE_DUPS_FIRST # When history limit is reached, delete duplicates first
setopt HIST_FIND_NO_DUPS # When searching in the history, do not show duplicates

# Shell Behaviour

setopt AUTOCD # Allows to change a directory by typing dirname, eg : `~/Downloads` instead of `cd ~/Downloads`
setopt NOBEEP # Disable sound on error
setopt NUMERIC_GLOB_SORT # sort file10 after file 9 rather than file 1

# Smart directory navigation
# Initialize zoxide
eval "$(zoxide init zsh)"

# Completion
# Load completion system
autoload -Uz compinit

# Initialize completion with cached metadata file
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # lowercase input matching

# Fuzzy finder
# macOS / Homebrew (Apple Silicon)
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
	source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
	source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

# Arch
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
	source /usr/share/fzf/key-bindings.zsh
	source /usr/share/fzf/completion.zsh
fi

# Modular Config Files

# fzf configuration
source "$ZDOTDIR/fzf.zsh"

# Aliases
source "$ZDOTDIR/aliases.zsh"

# Interactive alias finder (alias-helper)
source "$ZDOTDIR/alias-helper.zsh"

# Plugins and plugin manager
source "$ZDOTDIR/plugins.zsh"

# Prompt/theme
source "$ZDOTDIR/prompt.zsh"

# zoxide functions
source "$ZDOTDIR/zoxide.zsh"

# Background Git auto-fetch
source "$ZDOTDIR/git-fetch.zsh"

# Sudo wrapper
source "$ZDOTDIR/sudo.zsh"

# Custom keybindngs
source "$ZDOTDIR/bindings.zsh"
