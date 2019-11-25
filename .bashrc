# /etc/skel/.bashrc

export EDITOR=vi
export FZF_DEFAULT_OPTS='--multi --height=30%'

# Aliases
alias ..="cd .."
alias g='git'
fzvi ()
{
  local file=$(fzf)
  if [ -z "$file" ]; then
    return
  fi
  vi $file -p
}

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
        echo $DEVICE
        return 0
      fi
    else
      echo $DEVICE
      return 0
    fi
  else
    echo $DEVICE
    return 0
  fi
}

gimme_lab_device() {
  if [ ! -z $ATEST_DUT_IP ]
  then
    echo Cannot gimme_lab_device when you already have one locked!
    echo Current locked DUT: $ATEST_DUT_IP
    return 1
  fi
  if [ -z $1 ]
  then
    echo Please specify a board.
    return 1
  fi
  DEVICES=$(find_lab_device $1)
  if [ -z "$DEVICES" ]
  then
    echo No device found.
    return 1
  fi
  export ATEST_DUT_IP=$(echo $DEVICES | awk '{print $1;}')
  atest host mod --lock $ATEST_DUT_IP --lock_reason "Testing a server-side Autotest/Tast change"
  return $?
}

atest_that () {
  if [ -z $ATEST_DUT_IP ]
  then
    echo "Cannot run test_that if you haven't locked a DUT."
    return 1
  fi
  if [ -z $1 ]
  then
    echo "Please supply a test, such as firmware_FAFTSetup."
    return 1
  fi
  if [ -z $ATEST_BOARD ]; then
    echo 'Getting DUT info from atest host stat'
    export ATEST_BOARD=$(atest host stat $ATEST_DUT_IP | grep -oP '(?<=board:)\w+')
    echo ATEST_BOARD: $ATEST_BOARD
    export ATEST_SHOST=$(atest host stat $ATEST_DUT_IP | grep -oP '(?<=servo_host\s:\s)[a-z0-9-]+')
    echo ATEST_SHOST: $ATEST_SHOST
    export ATEST_SPORT=$(atest host stat $ATEST_DUT_IP | grep -oP '(?<=servo_port\s:\s)[0-9]+')
    echo ATEST_SPORT: $ATEST_SPORT
  fi
  cd ~/chromiumos/
  cmd=(cros_sdk test_that --autotest_dir=../third_party/autotest/files/ --board=$ATEST_BOARD $ATEST_DUT_IP --args="servo_host=$ATEST_SHOST servo_port=$ATEST_SPORT" $1)
  echo Running cmd: "${cmd[@]}"
  "${cmd[@]}"
  return $?
}

unlock_lab_device() {
  if [ -z $ATEST_DUT_IP ]
  then
    echo Can\'t unlock lab device when \$ATEST_DUT_IP is unset!
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
    echo "Missing arg: dut_ip"
    echo $USAGE
    return 1
  else
    DUT_IP=1
  fi
  if [ -z $2 ]
  then
    echo "Missing arg: test_name"
    echo $USAGE
    return 1
  fi
  DUT_IP=$1
  TEST_NAME=$2
  SKYLAB_BOARD=$(skylab dut-info $DUT_IP | grep -oP '(?<=Board:)\s*\S+' | xargs)
  SKYLAB_SHOST=$(skylab dut-info $DUT_IP | grep -oP '(?<=servo_host)\s*\S+' | xargs)
  SKYLAB_SPORT=$(skylab dut-info $DUT_IP | grep -oP '(?<=servo_port)\s*\w+' | xargs)
  cd ~/chromiumos/
  cmd=(cros_sdk sudo test_that --autotest_dir=../third_party/autotest/files/ --board=$SKYLAB_BOARD $DUT_IP --args="servo_host=$SKYLAB_SHOST servo_port=$SKYLAB_SPORT" $TEST_NAME)
  echo Running cmd: "${cmd[@]}"
  "${cmd[@]}"
  return $?
}
