#!/usr/bin/env zsh

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
alias rgproto="rg -g '**.proto'"
alias rgpy="rg -g '**.py'"
alias rgstar="rg -g '**.star'"

# Misc conveniences.
alias ls="ls --color=auto"
alias zshrc="nvim ~/.dotfiles/.zshrc"

# Google-specific aliases.
if on_google_host; then
  # Note: `alias tmux=tmx2` is important and Google-specific, but it is handled
  # separately in tmux.zsh (which should be sourced before this).
  #
  # repo aliases.
  alias ru.="repo upload --cbr ."
  alias ru.y="repo upload --cbr . -y"
fi

# Host-specific aliases.
case $HOST in
  gregs-cool-cloudtop.c.googlers.com)
    # Android development conveniences
    alias HOW_TO_BUILD_ANDROID='echo "cd ~/al\n. build/envsetup.sh\nlunch cf_x86_64_al-trunk_staging-eng\nm installclean\nm"'
    ;;
esac

