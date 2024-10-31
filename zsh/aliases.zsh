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

# Google-specific aliases.
if on_google_host; then
  # Note: `alias tmux=tmx2` is important and Google-specific, but it is handled
  # separately in tmux.zsh (which should be sourced before this).

  # repo aliases.
  alias ru.="repo upload --cbr ."
  alias ru.y="repo upload --cbr . -y"

  # recipes aliases.
  alias rtt="./recipes.py test train"
  alias fart="git cl format --no-clang-format --python && ./recipes.py test train"

  # git aliases
  alias gups="git branch --set-upstream-to m/main"
fi

# Host-specific aliases.
case $HOST in
  gregs-cool-cloudtop.c.googlers.com)
    # Android development conveniences
    alias HOW_TO_BUILD_ANDROID='echo ". build/envsetup.sh\nlunch cf_x86_64_desktop-trunk_staging-eng\nm installclean\nm"'
    ;;
esac

