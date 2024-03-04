function n --description 'Runs a command from `nixpkgs`'
    nix run nixpkgs#$argv[1] -- $argv[2..-1]
end
