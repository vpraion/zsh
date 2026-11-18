# =========================================================
# Sudo wrapper
# =========================================================

# Automatically converts 'sudo nvim/vim/vi/nano' to 'sudo -e'
# to keep user Neovim configuration and avoid running editor as root.
sudo() {
    if [[ "$1" == (nvim|vim|vi|nano) ]]; then
        shift
        command sudo -e "$@"
        return
    fi

    command sudo "$@"
}
