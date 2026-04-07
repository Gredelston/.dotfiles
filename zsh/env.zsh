#!/usr/bin/env zsh

# Set up environment variables.

# Set up PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$PATH:$HOME/.cargo/bin

# Google-specific env.
if [[ -d "$HOME/depot_tools" ]]; then
	export PATH=$HOME/depot_tools:$PATH
fi

if [[ -f "$DOTFILES/corp-dotfiles/zsh/env.zsh" ]]; then
	source "$DOTFILES/corp-dotfiles/zsh/env.zsh"
fi

if [[ -e "$HOME/env.zsh" ]]; then
	source $HOME/env.zsh
fi
