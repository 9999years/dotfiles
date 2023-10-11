# Move `/nix/store/` paths to the front of `$PATH`.
# This helps us get the correct `$PATH` in Nix shells.
function prepend-nix-store-paths \
    --description "Move `/nix/store` paths to the front of `\$PATH`"
    set --local to_prepend

    for i in (seq (count $PATH))
        switch $PATH[$i]
            case "/nix/store/*"
                set --prepend to_prepend $i
        end
    end

    if test (count $to_prepend) -gt 0
        fish_add_path --global --move --path $PATH[$to_prepend]
    end
end
