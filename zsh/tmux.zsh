#!/usr/bin/env zsh

#######################################
# Check whether this shell should reexecute in tmux.
# Returns:
#   0 if should reexecute in tmux, else 1.
#######################################
function should_reexecute_in_tmux() {
  # Hosts that are primarily used to SSH into other machines
  # should not reexecute in tmux, or else we'll have nested
  # sessions.
  return $(
    case $HOST in
      gredelston-carbon-v9)
        false
        ;;
      *)
        # If we're already in a tmux session, don't reexecute.
        [[ -z "${TMUX}" ]]
        ;;
    esac
  )
}

# On Google machines, it is recommended to use tmx2 instead of tmux.
if on_google_host; then
  alias tmux=tmx2
fi

# Re-execute in tmux, if necessary.
if should_reexecute_in_tmux; then
  case $HOST in
    gregs-cool-cloudtop.c.googlers.com)
      session_name="work"
      ;;
    *)
      session_name="greg"
      ;;
  esac
  tmux new-session -A -s $session_name
fi

