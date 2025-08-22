function remove-nix-paths \
        --description 'Remove Nix paths from `$PATH` to avoid duplicate `$PATH` entries'
    set --local to_remove

    # Iterate in reverse order so that while we remove the paths we won't shift
    # the next indices.
    for i in (seq (count $PATH) -1 1)
        switch $PATH[$i]
            case "$HOME/.nix-profile/bin" \
                    "$XDG_STATE_HOME/nix/profile/bin" \
                    "$HOME/.local/state/nix/profile" \
                    "/nix/var/nix/profiles/default/bin"
                set --append to_remove $i
        end
    end

    if test (count $to_remove) -gt 0
        # Note: `$to_remove` is an array so this gets expanded out to
        # `PATH[$to_remove[1]] PATH[$to_remove[2]] ...`.
        set --erase PATH[$to_remove]
    end
end
