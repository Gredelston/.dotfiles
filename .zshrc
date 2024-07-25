# Re-execute in Tmux.
if [ "$TMUX" = "" ]; then tmx2 new-session -A; fi

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

# Aliases
alias ga.="git add ."
alias gca="git commit --amend"
alias gcan="git commit --amend --no-edit"
alias gco="git checkout"
alias gc-="git checkout -"
alias gd="git diff"
alias gl="git log"
alias gs="git status"
alias nvim="/opt/nvim-linux64/bin/nvim"
alias zshrc="nvim ~/.zshrc"

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
bindkey '^[[3~' delete-char           # enables DEL key proper behaviour
bindkey '^[[1;5C' forward-word        # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word       # [Ctrl-LeftArrow] - move backward one word
bindkey  "^[[H"   beginning-of-line   # [Home] - goes at the begining of the line
bindkey  "^[[F"   end-of-line         # [End] - goes at the end of the line

# Enable history saving, from go/zsh-prompt
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt share_history        # share history between multiple instances of zsh

# Setup plugins
source ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/powerlevel10k/powerlevel9k.zsh-theme

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Cog (CitC-on-Git-on-Borg)
source /etc/bash_completion.d/cogd

# Enable differenciated colors per file type (ls) -- from go/zsh-prompt
alias ls="ls --color=auto"
if [[ -f /usr/local/google/home/gredelston/.local/share/lscolors.sh ]]; then
  source "/usr/local/google/home/gredelston/.local/share/lscolors.sh"
fi
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  

# Android development conveniences
export BOARD_CF="cf_x86_64_al"
alias LUNCH_CF='lunch ${BOARD_CF}-trunk_staging-eng'
alias HOW_TO_BUILD_ANDROID='echo "cd ~/al\n. build/envsetup.sh\nLUNCH_CF\nm installclean\nm"'

