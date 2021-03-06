# /etc/skel/.bashrc

export EDITOR=vi
export FZF_DEFAULT_OPTS='--multi --height=30%'
export BROWSER=w3m
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
    export TMUX_CMD="tmx2"
    alias gogo='cd ${HOME}/chrome_infra/infra/go && eval `./env.py` && cd src/infra/cros'
elif [[ $(hostname) =~ "gregs-cool-solus" ]]; then
    export JAVAHOME=/usr/lib/openjdk-11/bin
    export PATH=${PATH}:${JAVAHOME}
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

# atest alias: Find a device
find_lab_device() {
  DEVICE=$(atest host list --label=pool:faft-test,board:$1 --status=Ready --hostnames-only --unlocked | grep -e "chromeos1-")
  if [ -z "$DEVICE" ] # If empty
  then
    DEVICE=$(atest host list --label=pool:faft-test,board:$1 --status=Ready --hostnames-only --unlocked | grep -e "chromeos[246]-")
    if [ -z "$DEVICE" ]
    then
      DEVICE=$(atest host list --label=pool:suites,board:$1 --status=Ready --hostnames-only --unlocked | grep -e "chromeos[246]-")
      if [ -z "$DEVICE" ]
      then
        return 1
      else
        greglog $DEVICE
        return 0
      fi
    else
      greglog $DEVICE
      return 0
    fi
  else
    greglog $DEVICE
    return 0
  fi
}

gimme_lab_device() {
  if [ ! -z $ATEST_DUT_IP ]
  then
    greglog Cannot gimme_lab_device when you already have one locked!
    greglog Current locked DUT: $ATEST_DUT_IP
    return 1
  fi
  if [ -z $1 ]
  then
    greglog Please specify a board.
    return 1
  fi
  DEVICES=$(find_lab_device $1)
  if [ -z "$DEVICES" ]
  then
    greglog No device found.
    return 1
  fi
  export ATEST_DUT_IP=$(echo $DEVICES | awk '{print $1;}')
  atest host mod --lock $ATEST_DUT_IP --lock_reason "Testing a server-side Autotest/Tast change"
  return $?
}

atest_that () {
  if [ -z $ATEST_DUT_IP ]
  then
    greglog "Cannot run test_that if you haven't locked a DUT."
    return 1
  fi
  if [ -z $1 ]
  then
    greglog "Please supply a test, such as firmware_FAFTSetup."
    return 1
  fi
  if [ -z $ATEST_BOARD ]; then
    greglog 'Getting DUT info from atest host stat'
    export ATEST_BOARD=$(atest host stat $ATEST_DUT_IP | grep -oP '(?<=board:)\w+')
    greglog ATEST_BOARD: $ATEST_BOARD
    export ATEST_SHOST=$(atest host stat $ATEST_DUT_IP | grep -oP '(?<=servo_host\s:\s)[a-z0-9-]+')
    greglog ATEST_SHOST: $ATEST_SHOST
    export ATEST_SPORT=$(atest host stat $ATEST_DUT_IP | grep -oP '(?<=servo_port\s:\s)[0-9]+')
    greglog ATEST_SPORT: $ATEST_SPORT
  fi
  cd ~/chromiumos/
  cmd=(cros_sdk test_that --autotest_dir=../third_party/autotest/files/ --board=$ATEST_BOARD $ATEST_DUT_IP --args="servo_host=$ATEST_SHOST servo_port=$ATEST_SPORT" $1)
  greglog "${cmd[@]}"
  "${cmd[@]}"
  return $?
}

unlock_lab_device() {
  if [ -z $ATEST_DUT_IP ]
  then
    greglog Can\'t unlock lab device when \$ATEST_DUT_IP is unset!
    return 1
  fi
  atest host mod --unlock $ATEST_DUT_IP
  unset ATEST_DUT_IP
  unset ATEST_BOARD
  unset ATEST_SHOST
  unset ATEST_SPORT
}

run_skylab() {
  USAGE="USAGE: run_skylab dut_ip test_name"
  if [ -z $1 ]
  then
    greglog "Missing arg: dut_ip"
    greglog $USAGE
    return 1
  else
    DUT_IP=1
  fi
  if [ -z $2 ]
  then
    greglog "Missing arg: test_name"
    greglog $USAGE
    return 1
  fi
  DUT_IP=$1
  TEST_NAME=$2
  SKYLAB_BOARD=$(skylab dut-info $DUT_IP | grep -oP '(?<=Board:)\s*\S+' | xargs)
  SKYLAB_SHOST=$(skylab dut-info $DUT_IP | grep -oP '(?<=servo_host)\s*\S+' | xargs)
  SKYLAB_SPORT=$(skylab dut-info $DUT_IP | grep -oP '(?<=servo_port)\s*\w+' | xargs)
  cd ~/chromiumos/
  cmd=(cros_sdk sudo test_that --autotest_dir=../third_party/autotest/files/ --board=$SKYLAB_BOARD $DUT_IP --args="servo_host=$SKYLAB_SHOST servo_port=$SKYLAB_SPORT" $TEST_NAME)
  greglog "${cmd[@]}"
  "${cmd[@]}"
  return $?
}

lease_and_run() {
  USAGE="USAGE: lease_and_run dut_ip test_name"
  if [ -z $1 ]
  then
    greglog "Missing arg: dut_ip"
    greglog $USAGE
    return 1
  else
    DUT_IP=1
  fi
  if [ -z $2 ]
  then
    greglog "Missing arg: test_name"
    greglog $USAGE
    return 1
  fi
  skylab lease-dut $1
  run_skylab $1 $2
}

# Start tmux
if [[ ! $TERM =~ screen ]]; then
     exec tmux
fi

. ${HOME}/.dotfiles/.aerial-tramway
