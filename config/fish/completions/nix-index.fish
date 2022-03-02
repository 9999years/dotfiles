# nix-index 0.1.2

complete -c nix-index -f                        -d "Builds an index for nix-locate"
complete -c nix-index -s h -l help              -d "Prints help information"
complete -c nix-index      -l show-trace        -d "Show a stack trace in case of Nix expression evaluation errors"
complete -c nix-index -s V -l version           -d "Prints version information"
complete -c nix-index -s d -l db -r -F          -d "Directory where the index is stored [default: $HOME/.cache/nix-index/]"
complete -c nix-index -s c -l compression -r -f -d "Zstandard compression level [default: 22]"
complete -c nix-index -s f -l nixpkgs -r -F     -d "Path to nixpgs for which to build the index, as accepted by nix-env -f [default: <nixpkgs>]"
complete -c nix-index -s r -l requests -r -f    -d "make NUM http requests in parallel [default: 100]"
