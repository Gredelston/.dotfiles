#######################################
# Pretty-print a line of text in a block of octothorps.
#######################################
function octothorprint_line() {
  local main_line="# $1 #"
  local line_length=$(echo -n $main_line | wc -m)
  local octothorp_line=$(repeat $line_length print -rn '#')
  print $octothorp_line
  print $main_line
  print $octothorp_line
}

#######################################
# Check whether this host is a Google machine.
# Returns:
#   0 if the host is a Google machine, else 1.
#######################################
function on_google_host() {
  return $(test -d '/google')
}

#######################################
# Print a file's size.
#######################################
function filesize() {
  local human_readable=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h)
        human_readable=true
        shift
        ;;
      -*)
        echo "Unexpected flag: $1"
        return 1
        ;;
      *) # Required positional arg.
        if [[ -z "$filename" ]]; then
          local filename="$1"
        else
          echo "Unexpected param: $1"
          return 1
        fi
        shift
        ;;
    esac
  done

  if [[ -z $filename ]]; then
    echo "Usage: filesize [-h|--human-readable] filename"
    return 1
  fi

  size_in_bytes=$(stat -c %s $filename)
  if $human_readable; then
    echo $(echo $size_in_bytes | numfmt --to=iec)
  else
    echo $size_in_bytes
  fi
}

# Google-specific functions.
if on_google_host; then

  #######################################
  # Make sure we have a valid gcert.
  #######################################
  function gcert_if_needed() {
    if ! $(gcertstatus -quiet); then
      echo "Need to gcert."
      gcert
    fi
  }

  #######################################
  # Convenience wrapper around repo sync.
  #######################################
  function repo_sync() {
    gcert_if_needed
    repo sync
  }
  alias repo-sync="repo_sync"

  #######################################
  # Find the directory among the working dir's ancestors that contains .repo/.
  #######################################
  function repo_root() {
    local dir="$PWD"
    while [[ $dir != "/" ]]; do
      if [[ -d "$dir/.repo" ]]; then
        echo "$dir"
        return 0
      fi
      dir="${dir:h}"
    done

    echo "No .repo/ dir found." >&2
    return 1
  }

  #######################################
  # Open the default manifest file for the active repo.
  #######################################
  function open_manifest() {
    nvim $(repo_root)/.repo/manifests/default.xml
  }

  #######################################
  # Repo sync all of the repo projects
  #######################################
  function repo-sync-all() {
    gcert_if_needed
    local SUCCESSFUL_PROJECTS=()
    local FAILED_PROJECTS=()
    local NUM_PROJECTS=0
    for subdir in $(ls $HOME); do
      if [ ! -d $HOME/$subdir/.repo ]; then
        continue
      fi

      print
      octothorprint_line "Syncing repo project: ~/$subdir"
      print

      let NUM_PROJECTS++
      pushd -q $HOME/$subdir
      if repo_sync; then
        SUCCESSFUL_PROJECTS+=($subdir)
      else
        FAILED_PROJECTS+=($subdir)
      fi
      popd -q
    done

    echo
    echo "Done syncing $NUM_PROJECTS projects."
    echo "$#SUCCESSFUL_PROJECTS successful projects: $SUCCESSFUL_PROJECTS"
    echo "$#FAILED_PROJECTS failed projects: $FAILED_PROJECTS"
  }

  #######################################
  # Extract the kernel version from a .ko file.
  #######################################
  function vermagic() {
    local target_file=$1
    local vermagic_line=$( egrep -haom1 'vermagic=.*' $target_file )
    local vermagic_keyval=$( echo $vermagic_line | awk ' { print $1 } ' )
    local vermagic_value=$( echo $vermagic_keyval | sed s/vermagic=// )
    print $vermagic_value
  }

  #######################################
  # Push a commit to Gerrit for review, outside of `repo`.
  #######################################
  function push_to_gerrit() {
    git push origin HEAD:refs/for/$1
  }

  #######################################
  # Check whether the user is currently in a Piper workspace.
  # Returns:
  #   0 if the pwd is in a Piper workspace, else 1.
  #######################################
  function in_piper_workspace() {
    p4 client -o | grep -q 'Client:\s*[^:]*:[^:]*:[0-9]*:citc'
  }

  #######################################
  # Check whether the user is currently in a Fig workspace.
  # Returns:
  #   0 if the pwd is in a Fig workspace, else 10.
  #######################################
  function in_fig_workspace() {
    hg root &>/dev/null
  }

  #######################################
  # Within a Piper/Fig workspace, cd to the cros-ci-oncall directory.
  #######################################
  function goto_ci_oncall() {
    if in_piper_workspace; then
      g4d
      cd ..
    elif in_fig_workspace; then
      cd $(hg root)
    else
      echo 'Must be in a Piper or Fig workspace!'
      return 1
    fi
    cd company/teams/chrome/ops/chromeos/chromeos-infra/continuous_integration
    cd on-call
  }
fi

# Host-specific functions.
case $HOST in

  # My Google laptop.
  gredelston-carbon-v9)

    #######################################
    # Check whether we already have a gcert certificate.
    # If not, run gcert.
    #######################################
    cloudtop() {
      gcert_if_needed
      ssh gregs-cool-cloudtop.c.googlers.com
    }

    #######################################
    # Flash an OS image onto a USB stick.
    #######################################
    flash_image() {
      local image_path=$1
      if [ -z $image_path ]; then
	echo "Missing required positional arg: image_path"
	return 1
      elif [ ! -e $image_path ]; then
	echo "Invalid image $image_path: file not found"
	return 1
      elif [[ $image_path != *.bin ]]; then
	echo "Invalid image $image_path: must end in .bin"
	return 1
      fi
      sudo dd if=$image_path of=/dev/sda bs=8M oflag=sync status=progress
    }
    ;;
esac

