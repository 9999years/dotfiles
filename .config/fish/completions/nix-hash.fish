complete -c nix-hash -l type -d 'Use the specified cryptographic hash algorithm.' \
    -r -f -a "md5 sha1 sha256 sha512"
complete -c nix-hash -l flat --description 'Print the cryptographic hash of the contents of each regular file path.'
complete -c nix-hash -l base32 --description 'Print the hash in a base-32 representation rather than hexadecimal.'
complete -c nix-hash -l truncate --description 'Truncate hashes longer than 160 bits (such as SHA-256) to 160 bits.'
complete -c nix-hash -l to-base16 -x --description "Don't hash anything, but convert the base-32 hash representation hash to hexadecimal."
complete -c nix-hash -l to-base32 -x --description "Don't hash anything, but convert the hexadecimal hash representation hash to base-32."
complete -c nix-hash -l help --description "Print help."
complete -c nix-hash -l version --description "Print version information."