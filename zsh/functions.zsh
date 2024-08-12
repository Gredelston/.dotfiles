#######################################
# Check whether this host is a Google machine.
# Returns:
#   0 if the host is a Google machine, else 1.
#######################################
function on_google_host() {
  return $(test -d '/google')
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

