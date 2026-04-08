#!/usr/bin/env zsh

# Set up environment variables.

# Set up PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/bin

# Google-specific env.
if [[ -d "$HOME/depot_tools" ]]; then
	export PATH=$HOME/depot_tools:$PATH
fi

export CORP_DOTFILES="$DOTFILES/corp-dotfiles"
if [[ -f "$CORP_DOTFILES/zsh/env.zsh" ]]; then
	source "$CORP_DOTFILES/zsh/env.zsh"
fi

if [[ -e "$HOME/env.zsh" ]]; then
	source $HOME/env.zsh
fi
