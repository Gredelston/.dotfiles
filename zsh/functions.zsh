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
    local SUCCESSFUL_PROJECTS=()
    local FAILED_PROJECTS=()
    local NUM_PROJECTS=0
    for subdir in $(ls $HOME); do
      if [ ! -d $HOME/$subdir/.repo ]; then
        continue
      fi

      echo
      echo "###################################"
      echo "# Syncing repo project: ~/$subdir"
      echo "###################################"
      echo

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

