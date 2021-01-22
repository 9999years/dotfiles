# for nix-locate 0.1.2

function __nix_locate_has_dashdash -d 'true if -- has been given as a command-line option'
    contains -- -- (commandline -cpo)
end

# no file completions
complete -c nix-locate -f -d "Quickly finds the derivation providing a certain file"

complete -c nix-locate      -l at-root       -d "Treat PATTERN as an absolute file path, so it only matches starting from the root of a package. This means that the pattern `/bin/foo` only matches a file called `/bin/foo` or `/bin/foobar` but not `/libexec/bin/foo`."
complete -c nix-locate -s h -l help          -d "Prints help information"
complete -c nix-locate -s 1 -l minimal       -d "Only print attribute names of found files or directories. Other details such as size or store path are omitted. This is useful for scripts that use the output of nix-locate."
complete -c nix-locate      -l no-group      -d "Disables grouping of paths with the same matching part. By default, a path will only be printed if the pattern matches some part of the last component of the path. For example, the pattern `a/foo` would match all of `a/foo`, `a/foo/some_file` and `a/foo/another_file`, but only the first match will be printed. This option disables that behavior and prints all matches."
complete -c nix-locate -s r -l regex         -d "Treat PATTERN as regex instead of literal text. Also applies to --name option."
complete -c nix-locate      -l top-level     -d "Only print matches from packages that show up in nix-env -qa."
complete -c nix-locate -s V -l version       -d "Prints version information"
complete -c nix-locate -s w -l whole-name    -d "Only print matches for files or directories whose basename matches PATTERN exactly. This means that the pattern `bin/foo` will only match a file called `bin/foo` or `xx/bin/foo` but not `bin/foobar`."
complete -c nix-locate -s d -l db -r -F             -d "Directory where the index is stored [default: $HOME/.cache/nix-index/]"
complete -c nix-locate      -l hash -r -f           -d "Only print matches from the package that has the given HASH."
complete -c nix-locate -s p -l package -r -f        -d "Only print matches from packages whose name matches PATTERN."
complete -c nix-locate -s t -l type -r -a "d x r s" -d "Only print matches for files that have this type. If the option is given multiple times, a file will be printed if it has any of the given types. [possible values: d, x, r, s]"

complete -c nix-locate -f -a "auto always never" -n __nix_locate_has_dashdash -d "Whether to use colors in output. If auto, only use colors if outputting to a terminal"
