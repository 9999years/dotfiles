function nsn --description "`nix shell` helper for nixpkgs entries"
    set --local pkgs nix shell
    for arg in $argv
        if string match --quiet -- "*#*" $arg
            # Unqualified installables pass through unchanged.
            set --append pkgs $arg
        else if string match --quiet -- "-*" $arg
            # Arguments pass through unchanged.
            set --append pkgs $arg
        else
            set --append pkgs "nixpkgs#$arg"
        end
    end

    echo (set_color --bold cyan)"nix shell $pkgs"(set_color normal)
    nix shell $pkgs
end
