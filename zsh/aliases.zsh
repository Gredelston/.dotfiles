#!/usr/bin/env zsh

#######################################
# Tell the user to use a different command.
#######################################
function suggest_better_command() {
  echo "Use \`$1\` instead!"
}

# Git aliases.
alias ga.="git add ."
alias gb="git branch"
alias gca="git commit --amend"
alias gcan="git commit --amend --no-edit"
alias gcm="git checkout main"
alias gco="git checkout"
alias gc-="git checkout -"
alias gd="git diff"
alias gdc="git diff --cached"
alias gdh="git diff HEAD^"
alias gl="git log"
alias gs="git status"

# rg (ripgrep) aliases.
# TODO: Remove once I've gotten accustomed to -t.
alias rgproto="suggest_better_command 'rg -t protobuf'"
alias rgpy="suggest_better_command 'rg -t py'"
alias rgmk="suggest_better_command 'rg -t make'"
alias rgstar="suggest_better_command 'rg -t star'"

# Misc conveniences.
alias ls="ls --color=auto"
alias zshrc="nvim ~/.dotfiles/.zshrc"
alias e="eza"
alias fd="fdfind"

# Google-specific aliases.
if on_google_host; then
  source $DOTFILES/corp-dotfiles/zsh/aliases.zsh
fi
