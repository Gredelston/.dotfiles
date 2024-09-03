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
    ;;
esac

