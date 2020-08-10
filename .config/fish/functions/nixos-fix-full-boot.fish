# Defined in /tmp/fish.L8naA7/nixos-full-boot-fix.fish @ line 2
function nixos-fix-full-boot \
        -d "Fix a full /boot partition in NixOS by removing old generations."
    echo -s (set_color --bold brcyan) "Removing old generations" (set_color normal)
    echo -s (set_color --underline ) "sudo nix-env --delete-generations old" \
        (set_color normal) (set_color --dim) \
        "  # our profile, all non-current generations" (set_color normal)
    sudo nix-env --delete-generations old
    echo -s (set_color --underline ) "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2" \
        (set_color normal) (set_color --dim) \
        "  # system profile, all but the last 2 generations" (set_color normal)
    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
    echo -s (set_color --bold brcyan) \
        "Finished removing old generations; consider additionally cleaning the nix store:" \
        (set_color normal)
    echo "    " (set_color --bold green) "sudo nix-store --gc" (set_color normal)
    echo "    " (set_color --bold green) "sudo nix-collect-garbage -d" (set_color normal)
end
