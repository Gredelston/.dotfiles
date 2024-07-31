#######################################
# Check whether this host is a Google machine.
# Returns:
#   0 if the host is a Google machine, else 1.
#######################################
function on_google_host() {
  return $(test -d '/google')
}

# Host-specific functions.
case $HOST in
  gredelston-carbon-v9)
    cloudtop() {
      if ! $(gcertstatus -quiet); then
	echo "Need to gcert."
	gcert
      fi
      ssh gregs-cool-cloudtop.c.googlers.com
    }
    ;;
esac
