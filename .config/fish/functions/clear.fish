# Defined in /tmp/fish.FeQd6L/clear.fish @ line 2
function clear
    command clear
    set -ge __prompt_last_dir
    # Then, if we're running tmux, clear the backscroll buffer too.
    # This lets us scroll all the way up without seeing the stuff we
    # thought we just cleared.
    if test -n "$TMUX"
        tmux clear-history
    end
end
