# Defined in /var/folders/dm/2kd_hgp51qx5v41_4ct5c8tw001d24/T//fish.pNd6bl/rebuild.fish @ line 2
function rebuild --description 'Rebuilds the current NixOS configuration.'
    if is_darwin
        set __nix_pkg_expr "$HOME/.config/nix-config/macos.nix"
        echo -s (set_color --bold --underline) "On MacOS; building environment from $__nix_pkg_expr" (set_color normal)
        echo "Installing:"
        nix-instantiate --eval --strict \
            --expr "builtins.map (p: p.name) (import $__nix_pkg_expr {})"
        nix-env --install --remove-all --file "$__nix_pkg_expr"
    else
        pushd /etc/nixos
        if not sudo sh -c "git pull --no-edit"
            read --local \
                --prompt-str (echo -s -n (set_color --bold "red") \
                                "git pull failed. Reset to upstream? [y/n] " \
                                (set_color normal)) \
                shouldReset
            switch "$shouldReset"
                case y Y
                    echo -s (set_color --bold --underline) "Resetting." (set_color normal)
                    sudo sh -c "git reset --hard origin/main"
                case n N
                    echo -s (set_color --bold --underline) "OK, exiting." (set_color normal)
                    false
                    return
                case "*"
                    echo -s (set_color --bold red) "Unrecognized input '$shouldReset', exiting." (set_color normal)
                    false
                    return
            end
        end
        # Log curent commit
        echo "/etc/nixos is now at commit:"
        git log HEAD^1..HEAD --oneline
        sudo ./init.py
        sudo sh -c "nixos-rebuild switch $argv"
        popd
    end
end
