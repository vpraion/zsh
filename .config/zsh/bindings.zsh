# Bindings

# Cursor shape per vi mode
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

# Disable command mode line highlight
ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# zsh-vi-mode resets all bindings on init, so custom bindings
# must be registered via this hook to survive.
zvm_after_init() {
	# Load fzf
	eval "$(fzf --zsh)"
	# Ctrl+Right -> move forward one word
	bindkey '^[[1;5C' forward-word

	# Ctrl+Left -> move backward one word
	bindkey '^[[1;5D' backward-word

	# Ctrl+F -> fzf file picker (no hidden files)
	bindkey '^F' _fzf_file_no_hidden

	# Ctrl+G -> fzf ripgrep interactive content search
	bindkey '^G' _fzf_grep

	# Ctrl+Space -> fzf alias helper
	bindkey '^@' _alias_helper_widget

	# Ctrl+\ -> toggle autosuggestions
	bindkey '^\' autosuggest-toggle

	# Up/Down -> history search by substring
	bindkey '^[[A' history-substring-search-up
	bindkey '^[[B' history-substring-search-down
	
	# Ctrl+O -> jump to a folder known by zoxide
	bindkey '^O' _zoxide_fzf_widget
}
