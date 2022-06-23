# /etc/skel/.bashrc

export EDITOR=vi
export FZF_DEFAULT_OPTS='--multi --height=30%'
export BROWSER=w3m
export GOPATH=${HOME}/go
export DOTFILES=${HOME}/.dotfiles
alias ls="ls -B --color"
alias netflix='firefox www.netflix.com'
alias chromiumgo='cd ${HOME}/chromiumos; cros_sdk --no-ns-pid --enter'

# Path
export PATH=${PATH}:${HOME}/scripts
export PATH=${PATH}:${HOME}/bin
export PATH=${PATH}:${HOME}/.local/bin
export PATH=${PATH}:/usr/local/go/bin

# Host-specific info
if [[ $(hostname) =~ "gregs-cool-workstation" ]]; then
    . ${DOTFILES}/.bashrc-google-workstation
elif [[ $(hostname) =~ "gregs-cool-solus" ]]; then
    . ${DOTFILES}/.bashrc-solus
else
    export TMUX_CMD="tmux"
fi

# Logging
greglog () {
  echo -e "\e[1m\e[36m\e[47mGE> \e[0m\e[36m\e[47m$@\e[0m"
  return
}

# Grep for unique files
filegrep () {
  grep -rI $1 | awk -F':' ' { print $1 } ' | uniq
  return
}

# Aliases
alias ..="cd .."
alias g="git"
alias ga.="git add ."
alias gca="git commit --amend"
alias gcan="git commit --amend --no-edit"
alias gd="git diff"
alias gdc="git diff --cached"
alias gdh="git diff HEAD^"
alias gs="git status"
alias resource=". ${HOME}/.bashrc"
alias tmux-zero='${TMUX_CMD} switch -t 0 && exit'
alias vip="vi -p"

# fzvi opens file(s) selected via fzf in vi
fzvi ()
{
  local file=$(fzf)
  if [ -z "$file" ]; then
    return
  fi
  vi $file -p
}

# Utility function: are we in chroot?
in_chroot() {
	test -e /etc/cros_chroot_version
}

# PS1
source ~/.dotfiles/.git-prompt.sh
PROMPT_COMMAND=__prompt_command # Generate PS1 after commands
__prompt_command() {
	local EXIT="$?" # Keep this first!
	PS1=""

	local BLUE='\[\033[0;34m\]'
	local BLUE_BOLD='\[\033[01;34m\]'
	local GREEN='\[\033[0;32m\]'
	local ORANGE='\[\033[0;33m\]'
	local RED='\[\033[0;31m\]'
	local WHITE='\[\033[00m\]'

	PS1_GITBRANCH=${WHITE}'$(r=$?; __git_ps1 "(%s)"; exit $r)'
	PS1_PWD="${BLUE_BOLD}\w"
	PS1_DELIMITER="${WHITE}|"
	PS1_TIMESTAMP="${BLUE}\t"
	PS1_ERRORMARK=`if [[ $EXIT -eq 0 ]]; then echo "${GREEN}[✓]"; else echo "${RED}[✘ $EXIT]"; fi`
	PS1_HISTORY="${ORANGE}[\!]"
	PS1_LAMBDA=${WHITE}λ
	PS1="$PS1_GITBRANCH $PS1_PWD $PS1_DELIMITER $PS1_TIMESTAMP $PS1_ERRORMARK\n$PS1_HISTORY $PS1_LAMBDA "
	if in_chroot; then
		PS1="(cr) $PS1"
	fi
}

# upto, from unix.stackexchange
upto ()
{
  if [ -z "$1" ]; then
    return
  fi
  local upto=$1
  cd "${PWD/\/$upto\/*//$upto}"
}

# upto tab completion
_upto()
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  local d=${PWD//\//\ }
  COMPREPLY=( $( compgen -W "$d" -- "$cur" ) )
}
complete -F _upto upto

# calc, from unix.stackexchange
calc () {
  bc -l <<< "$@"
}

# FZF fun:
fzf_git_diff() {
    git diff --name-status "${@:-HEAD^}" | \
    fzf --ansi --no-sort \
        --preview "echo {} | cut -f2- | xargs -I@ sh -c 'git show --color=always --oneline @'"
}

alias gdiff='fzf_git_diff'


fzf_git_log_pickaxe() {
     if [[ $# == 0 ]]; then
         echo 'Error: search term was not provided.'
         return
     fi
     local selections=$(
       git log --oneline --color=always -S "$@" |
         fzf --ansi --no-sort --no-height \
             --preview "git show --color=always {1}"
       )
     if [[ -n $selections ]]; then
         local commits=$(echo "$selections" | cut -d' ' -f1 | tr '\n' ' ')
         git show $commits
     fi
}
alias glS='fzf_git_log_pickaxe'

# Start tmux
if [ -z $TMUX ]; then
     exec tmux
fi

. ${DOTFILES}/.aerial-tramway
