# Modern CLI replacements

# [eza --icons] Better ls
alias ls='eza --icons=auto'

# [eza -lhg --icons --git] Detailed listing
alias ll='eza -lhg --icons=auto --git'

# [eza -lahg --icons --git] Detailled listing including hidden files
alias la='eza -lahg --icons=auto --git'

# [eza --tree --icons] Tree view
alias tree='eza --tree --icons=auto'

# [bat] cat to bat
alias cat='bat'

# Use ls completion rules for eza (command options and arguments).
compdef eza=ls

# Core utilities

# [rg --color=auto] Fast pattern search using ripgrep
alias grep='rg --color=auto'

# [diff --color=auto] Compare files line by line with color
alias diff='diff --color=auto'

# [df -h] Show disk space usage in human readable format
alias df='df -h'

# [nvim] Open Neovim editor
alias vim='nvim'

# [vim] Open Neovim editor
alias vi='nvim'

# [nano] Forbid nano for the meantime
alias nano='nvim'

# [sudo -e] Edit file securely with user editor using sudo privileges
alias sudoedit='sudo -e'

# [sudo -e] Edit file securely with user editor using sudo privileges
alias svi='sudo -e'

# [mdcat -p --margin --emoji] View rendered markdown file
alias mdcat='mdcat -p --margin --emoji'

# Git

# Status

# [git status] Show the working tree status
alias gs='git status'

# [git status -s] Show the working tree status in short format
alias gss='git status -s'

# Add & Stage

# [git add] : Add file contents to the staging area
alias ga='git add'

# [git add --all] Add all changes (including untracked and deletions) to staging
alias gaa='git add --all'

# [git add -p] Interactively choose hunks of patch to add to staging
alias gap='git add -p'

# Commit

# [git commit] Record changes to the repository using commit template
alias gc='git commit'

# [git commit -m] Record changes with an inline commit message
alias gcm='git commit -m'

# [git commit --ammend] Amend the previous commit (re-open editor)
alias gca='git commit --amend'

# [git commit --ammend --no-edit] Amend the previous commit without editing the commit message
alias gcan='git commit --amend --no-edit'

# Diff

# [git diff] Show changes between working tree and staging area
alias gd='git diff'

# [git diff --staged] Show changes staged for the next commit
alias gds='git diff --staged'

# Branch & Switch

# [git branch] List, create, or delete branches
alias gb='git branch'

# [git checkout] Switch branches or restore working tree files
alias gco='git checkout'

# [git checkout -b] Create and switch to a new branch
alias gcb='git checkout -b'

# [git switch] Switch to a specified branch
alias gsw='git switch'

# [git switch -c] Create and switch to a new branch (modern syntax)
alias gsc='git switch -c'

# Log

# [git log --graph ...] Show commit history as a colored visual graph
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# [git log --oneline -n 15] Show compact oneline commit history (last 15 commits)
alias glo='git log --oneline -n 15'

# Push & Pull

# [git push] Update remote refs along with associated objects
alias gp='git push'

# [git fetch] Fetches the remote repository status
alias gf='git fetch'

# [git pull] Fetch from and integrate with another repository or branch
alias gpl='git pull'

# [git push --force-with-lease] Force push safely without overwriting other people's work
alias gpf='git push --force-with-lease'

# Stash & Undo

# [git stash] Stash the changes in a dirty working directory away
alias gst='git stash'

# [git stash pop] Remove a single stashed state and apply it to current working tree
alias gstp='git stash pop'

# [git stash drop] Delete the latest stash
alias gstd='git stash drop'

# [git stash clear] Delete all stashes
alias gstclr='git stash clear'

# [git reset --soft HEAD~1] Undo the last commit while keeping changes in the staging area
alias guncommit='git reset --soft HEAD~1'


# Navigation

# [cd -] Return to the previous visited directory (cd -)
alias -- -='cd -'

