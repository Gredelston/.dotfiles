# Import other zshrc scripts.
export DOTFILES=$HOME/.dotfiles
# Start by sourcing functions, because we want them to be available, and
# functions.zsh shouldn't actually call anything.
source $DOTFILES/zsh/functions.zsh
# Then re-execute in tmux, if necessary.
source $DOTFILES/zsh/tmux.zsh
# Then other stuff that can happen in any order.
source $DOTFILES/zsh/aliases.zsh

# Set up PATH
export PATH=$HOME/.local/bin:$PATH

# Install zsh plugins.
if [[ ! -d $HOME/.zsh ]]; then mkdir $HOME/.zsh; fi
if [[ ! -d $HOME/.zsh/powerlevel10k ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.zsh/powerlevel10k
fi
if [[ ! -d $HOME/.zsh/fast-syntax-highlighting ]]; then
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting $HOME/.zsh/fast-syntax-highlighting
fi
if [[ ! -d $HOME/.zsh/zsh-autosuggestions ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh/zsh-autosuggestions
fi
if ! command -v zoxide > /dev/null; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Shell prompt by Powerlevel10k
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Zshoptions
setopt AUTO_CD # cd without "cd"

# Zoxide, for better cd.
if command -v zoxide > /dev/null; then
  eval "$(zoxide init zsh)"
else
  echo "WARNING: zoxide not installed"
fi

# Piper completions
if [[ -f /etc/bash_completion.d/g4d ]]; then
  . /etc/bash_completion.d/p4
  . /etc/bash_completion.d/g4d
fi

# Fig completions
if [[ -f /etc/bash_completion.d/hgd ]]; then
  . /etc/bash_completion.d/hgd
fi

# General Zsh autocompletion, from go/zsh-prompt
zstyle ':completion:*' menu yes select
zstyle ':completion::complete:*' use-cache 1  # enables completion matching
zstyle ':completion::complete:*' cache-path ~/.zsh/cache
zstyle ':completion:*' users root $USER  # fix lag in google3
autoload -Uz compinit && compinit -i

# Other Zsh configuration, from go/zsh-prompt
bindkey '^[[3~'   delete-char           # enables DEL key proper behaviour
bindkey '^[[1;5C' forward-word          # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word         # [Ctrl-LeftArrow] - move backward one word
bindkey  '^[[H'   beginning-of-line     # [Home] - goes at the begining of the line
bindkey  '^[[F'   end-of-line           # [End] - goes at the end of the line
bindkey  '\e[Z'   reverse-menu-complete # [Shift-Tab] - go back in the menu]

# Enable history saving, from go/zsh-prompt
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt share_history        # share history between multiple instances of zsh

# Setup plugins
source ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/powerlevel10k/powerlevel9k.zsh-theme

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Cog (CitC-on-Git-on-Borg)
if [[ -f /etc/bash_completion.d/cogd ]]; then
  source /etc/bash_completion.d/cogd
fi

# Enable differenciated colors per file type (ls) -- from go/zsh-prompt
if [[ -f /usr/local/google/home/gredelston/.local/share/lscolors.sh ]]; then
  source "/usr/local/google/home/gredelston/.local/share/lscolors.sh"
fi
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  

# ChromeOS workspace stuff
if on_google_host; then
  export PATH=$HOME/depot_tools:$PATH
fi
if [[ $HOST = gregs-cool-cloudtop.c.googlers.com ]]; then
  export SKIP_GCE_AUTH_FOR_GIT=1
fi

