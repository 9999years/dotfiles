# Defined in /tmp/fish.3u2CG6/nixos-full-boot-fix.fish @ line 2
function nixos-full-boot-fix
	sudo nix-env --delete-generations old
    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
    sudo nix-store --gc
    sudo nix-collect-garbage -d
end
