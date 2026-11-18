# XDG Base Directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZPLUGINDIR="$ZDOTDIR/plugins"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# GPG
# Only set GPG_TTY when stdin is connected to a terminal.
if [[ -t 0 ]]; then
    export GPG_TTY="$(tty)"
fi

# PATH

# In Zsh, `path` is an array tied to the `PATH` environment variable.
# `PATH` is a colon-separated string, while `path` is an array of directories.
# Modifying either one automatically updates the other.

typeset -U path # Automatically remove duplicate entries from path.

# Add user-local binaries to PATH.
path=("$HOME/.local/bin" $path)

# Pager
if [[ "$(uname -s)" == "Darwin" ]]; then
	if command -v /opt/homebrew/bin/bat >/dev/null 2>&1; then
		export MANPAGER="bat -l man -p"
	fi
else
	if command -v bat >/dev/null 2>&1; then
		export MANPAGER="bat -l man -p"
	fi
fi

# Starship
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"
