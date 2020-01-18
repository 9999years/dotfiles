# Defined in - @ line 2
function rebuild
	pushd /etc/nixos
    sudo sh -c "git pull --no-edit && nixos-rebuild switch $argv"
    popd
end
