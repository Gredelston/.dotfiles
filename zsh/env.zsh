#!/usr/bin/env zsh

# Set up environment variables.

# Google-specific env.
if on_google_host; then
  source $DOTFILES/corp-dotfiles/zsh/env.zsh
fi
