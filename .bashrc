# /etc/skel/.bashrc

export EDITOR=vi

# PS1
PS1_GITBRANCH='\[\033[00m\]$(r=$?; __git_ps1 "(%s)"; exit $r)'
PS1_PWD='\[\033[01;34m\]\w'
PS1_DELIMITER='\[\033[00m\]|'
PS1_TIMESTAMP='\[\033[0;34m\]`/bin/date +"%a %D %-I:%M:%S %p"`'
PS1_ERRORMARK='`if [[ $ERROR_STATUS -eq "0" ]]; then echo "\[\033[0;32m\][✓]"; else echo "\[\033[0;31m\][✘]"; fi`'
PS1_HISTORY='\[\033[0;33m\][\!]'
PS1_LAMBDA='\[\033[00m\]λ'
set_error_status () {
	ERROR_STATUS="$?"
}
export PROMPT_COMMAND=set_error_status
export PS1="$PS1_GITBRANCH $PS1_PWD $PS1_DELIMITER $PS1_TIMESTAMP $PS1_ERRORMARK\n$PS1_HISTORY $PS1_LAMBDA "

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
