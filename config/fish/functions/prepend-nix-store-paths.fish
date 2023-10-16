# Move `/nix/store/` paths to the front of `$PATH`.
# This helps us get the correct `$PATH` in Nix shells.
function prepend-nix-store-paths \
    --description "Move `/nix/store` paths to the front of `\$PATH`"
    set --local to_prepend

    # Iterate in reverse order so that once we prepend the paths they'll be in
    # the correct order.
    for i in (seq (count $PATH) -1 1)
        switch $PATH[$i]
            case "/nix/store/*"
                set --prepend to_prepend $i
        end
    end

    if test (count $to_prepend) -gt 0
        # Note: `$to_prepend` is an array so this gets expanded out to
        # `$PATH[$to_prepend[1]] $PATH[$to_prepend[2]] ...`.
        fish_add_path --global --move --path $PATH[$to_prepend]
    end
end
