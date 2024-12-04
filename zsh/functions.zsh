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
  source $DOTFILES/corp-dotfiles/zsh/functions.zsh
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

