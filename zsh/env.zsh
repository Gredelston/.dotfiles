#!/usr/bin/env zsh

# Set up environment variables.

# Set up PATH
export PATH=$HOME/.local/bin:$PATH

# Google-specific env.
if on_google_host; then
  export PATH=$HOME/depot_tools:$PATH
  source $DOTFILES/corp-dotfiles/zsh/env.zsh
fi
