# Defined in /tmp/fish.8YOpwj/clear.fish @ line 2
function clear
	
    command clear
    # Then, if we're running tmux, clear the backscroll buffer too.
    # This lets us scroll all the way up without seeing the stuff we
    # thought we just cleared.
    if test -n "$TMUX"
        tmux clear-history
    end
end
