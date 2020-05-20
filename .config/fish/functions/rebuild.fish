# Defined in /tmp/fish.j9Bn8N/rebuild.fish @ line 2
function rebuild --description 'Rebuilds the current NixOS configuration.'
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
                sudo sh -c "git reset --hard origin/master"
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
    sudo sh -c "nixos-rebuild switch $argv"
    popd
end
