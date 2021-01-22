function __nix_complete_subcommand -d 'adds a completion to a given subcommand'
  set -l subcommand $argv[1]
  complete -c nix -n "__fish_seen_subcommand_from $subcommand" $argv[2..-1]
end

function __nix_pkg_attr_names -d 'caches and returns a list of nix package names'
    if not test -e ~/.cache/nixpkgs-fish-completions/pkgs.txt
        mkdir -p ~/.cache/nixpkgs-fish-completions
        touch ~/.cache/nixpkgs-fish-completions/pkgs.txt
        # # names only:
        # nix-env --query --available --no-name --attr-path |  sed 's/^[^.]*\.//' > ~/.cache/nixpkgs-fish-completions/pkgs.txt
        # attrs and descriptions:
        nix-env --query --available --no-name --attr-path --description |  sed 's/  \+/\t/' > ~/.cache/nixpkgs-fish-completions/pkgs.txt
    end
    command cat ~/.cache/nixpkgs-fish-completions/pkgs.txt
end

set -l nix_hashes

set -l nix_commands \
    add-to-store build cat-nar cat-store copy copy-sigs doctor dump-path edit \
    eval hash-file hash-path log ls-nar ls-store optimise-store path-info \
    ping-store repl run search show-config show-derivation sign-paths \
    to-base16 to-base32 to-base64 to-sri upgrade-nix verify why-depends

function __nix_hash_types -d 'list nix hash algorithms for --type flag'
  echo "md5	use the old and insecure MD5 algorithm"
  echo "sha1	use the old and insecure SHA-1 algorithm"
  echo "sha256	use the preferred SHA-256 algorithm"
  echo "sha512	use the SHA-512 algorithm"
end

function __nix_options -d 'list nix options for the nix --option flag'
  echo "allow-import-from-derivation	Whether the evaluator allows importing the result of a derivation."
  echo "allow-new-privileges	Whether builders can acquire new privileges by calling programs with setuid/setgid bits or with file capabilities."
  echo "allow-unsafe-native-code-during-evaluation	Whether builtin functions that allow executing native code should be enabled."
  echo "allowed-impure-host-deps	Which prefixes to allow derivations to ask for access to (primarily for Darwin)."
  echo "allowed-uris	Prefixes of URIs that builtin functions such as fetchurl and fetchGit are allowed to fetch."
  echo "allowed-users	Which users or groups are allowed to connect to the daemon."
  echo "auto-optimise-store	Whether to automatically replace files with identical contents with hard links."
  echo "build-hook	The path of the helper program that executes builds to remote machines."
  echo "build-poll-interval	How often (in seconds) to poll for locks."
  echo "build-users-group	The Unix group that contains the build users."
  echo "builders	A semicolon-separated list of build machines, in the format of nix.machines."
  echo "builders-use-substitutes	Whether build machines should use their own substitutes for obtaining build dependencies if possible, rather than waiting for this host to upload them."
  echo "compress-build-log	Whether to compress logs."
  echo "connect-timeout	Timeout for connecting to servers during downloads. 0 means use curl's builtin default."
  echo "cores	Number of CPU cores to utilize in parallel within a build, i.e. by passing this number to Make via '-j'. 0 means that the number of actual CPU cores on the local host ought to be auto-detected."
  echo "diff-hook	A program that prints out the differences between the two paths specified on its command line."
  echo "download-attempts	How often Nix will attempt to download a file before giving up."
  echo "enforce-determinism	Whether to fail if repeated builds produce different output."
  echo "extra-platforms	Additional platforms that can be built on the local system. These may be supported natively (e.g. armv7 on some aarch64 CPUs or using hacks like qemu-user."
  echo "extra-sandbox-paths	Additional paths to make available inside the build sandbox."
  echo "extra-substituters	Additional URIs of substituters."
  echo "fallback	Whether to fall back to building when substitution fails."
  echo "filter-syscalls	Whether to prevent certain dangerous system calls, such as creation of setuid/setgid files or adding ACLs or extended attributes. Only disable this if you're aware of the security implications."
  echo "fsync-metadata	Whether SQLite should use fsync()."
  echo "gc-check-reachability	Whether to check if new GC roots can in fact be found by the garbage collector."
  echo "gc-reserved-space	Amount of reserved disk space for the garbage collector."
  echo "hashed-mirrors	A list of servers used by builtins.fetchurl to fetch files by hash."
  echo "http-connections	Number of parallel HTTP connections."
  echo "http2	Whether to enable HTTP/2 support."
  echo "impersonate-linux-26	Whether to impersonate a Linux 2.6 machine on newer kernels."
  echo "keep-build-log	Whether to store build logs."
  echo "keep-derivations	Whether the garbage collector should keep derivers of live paths."
  echo "keep-env-derivations	Whether to add derivations as a dependency of user environments (to prevent them from being GCed)."
  echo "keep-failed	Whether to keep temporary directories of failed builds."
  echo "keep-going	Whether to keep building derivations when another build fails."
  echo "keep-outputs	Whether the garbage collector should keep outputs of live derivations."
  echo "log-lines	If verbose-build is false, the number of lines of the tail of the log to show if a build fails."
  echo "max-build-log-size	Maximum number of bytes a builder can write to stdout/stderr before being killed (0 means no limit)."
  echo "max-free	Stop deleting garbage when free disk space is above the specified amount."
  echo "max-jobs	Maximum number of parallel build jobs. \"auto\" means use number of cores."
  echo "max-silent-time	The maximum time in seconds that a builer can go without producing any output on stdout/stderr before it is killed. 0 means infinity."
  echo "min-free	Automatically run the garbage collector when free disk space drops below the specified amount."
  echo "min-free-check-interval	Number of seconds between checking free disk space."
  echo "narinfo-cache-negative-ttl	The TTL in seconds for negative lookups in the disk cache i.e binary cache lookups that return an invalid path result"
  echo "narinfo-cache-positive-ttl	The TTL in seconds for positive lookups in the disk cache i.e binary cache lookups that return a valid path result."
  echo "netrc-file	Path to the netrc file used to obtain usernames/passwords for downloads."
  echo "plugin-files	Plugins to dynamically load at nix initialization time."
  echo "post-build-hook	A program to run just after each successful build."
  echo "pre-build-hook	A program to run just before a build to set derivation-specific build settings."
  echo "print-missing	Whether to print what paths need to be built or downloaded."
  echo "pure-eval	Whether to restrict file system and network access to files specified by cryptographic hash."
  echo "repeat	The number of times to repeat a build in order to verify determinism."
  echo "require-sigs	Whether to check that any non-content-addressed path added to the Nix store has a valid signature (that is, one signed using a key listed in 'trusted-public-keys'."
  echo "restrict-eval	Whether to restrict file system access to paths in \$NIX_PATH, and network access to the URI prefixes listed in 'allowed-uris'."
  echo "run-diff-hook	Whether to run the program specified by the diff-hook setting repeated builds produce a different result. Typically used to plug in diffoscope."
  echo "sandbox	Whether to enable sandboxed builds. Can be \"true\", \"false\" or \"relaxed\"."
  echo "sandbox-build-dir	The build directory inside the sandbox."
  echo "sandbox-dev-shm-size	The size of /dev/shm in the build sandbox."
  echo "sandbox-fallback	Whether to disable sandboxing when the kernel doesn't allow it."
  echo "sandbox-paths	The paths to make available inside the build sandbox."
  echo "secret-key-files	Secret keys with which to sign local builds."
  echo "show-trace	Whether to show a stack trace on evaluation errors."
  echo "stalled-download-timeout	Timeout (in seconds) for receiving data from servers during download. Nix cancels idle downloads after this timeout's duration."
  echo "store	The default Nix store to use."
  echo "substitute	Whether to use substitutes."
  echo "substituters	The URIs of substituters (such as https://cache.nixos.org/)."
  echo "sync-before-registering	Whether to call sync() before registering a path as valid."
  echo "system	The canonical Nix system name."
  echo "system-features	Optional features that this system implements (like \"kvm\")."
  echo "tarball-ttl	How long downloaded files are considered up-to-date."
  echo "timeout	The maximum duration in seconds that a builder can run. 0 means infinity."
  echo "trace-function-calls	Emit log messages for each function entry and exit at the 'vomit' log level (-vvvv)"
  echo "trusted-public-keys	Trusted public keys for secure substitution."
  echo "trusted-substituters	Disabled substituters that may be enabled via the substituters option by untrusted users."
  echo "trusted-users	Which users or groups are trusted to ask the daemon to do unsafe things."
  echo "use-case-hack	Whether to enable a Darwin-specific hack for dealing with file name collisions."
  echo "use-sqlite-wal	Whether SQLite should use WAL mode."
  echo "user-agent-suffix	String appended to the user agent in HTTP requests."
end

function __nix_complete_env
  set -x | sed 's/ /\t/'
end

complete -c nix       -l debug                  -d "[common] enable debug output"
complete -c nix       -l help                   -d "[common] show usage information"
complete -c nix       -l help-config            -d "[common] show configuration options"
complete -c nix       -l no-net                 -d "[common] disable substituters and consider all previously downloaded files up-to-date"
complete -c nix -s L  -l print-build-logs       -d "[common] print full build logs on stderr"
complete -c nix       -l quiet                  -d "[common] decrease verbosity level"
complete -c nix -s v  -l verbose                -d "[common] increase verbosity level"
complete -c nix       -l version                -d "[common] show version information"
complete -c nix       -l option -r -f -a "(__nix_options)" -d "[common] set a Nix configuration option (overriding nix.conf)"

complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a add-to-store -d 'add a path to the Nix store'
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a build -d 'build a derivation or fetch a store path'

complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a add-to-store     -d "add a path to the Nix store"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a build            -d "build a derivation or fetch a store path"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a cat-nar          -d "print the contents of a file inside a NAR file"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a cat-store        -d "print the contents of a store file on stdout"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a copy             -d "copy paths between Nix stores"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a copy-sigs        -d "copy path signatures from substituters (like binary caches)"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a doctor           -d "check your system for potential problems"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a dump-path        -d "dump a store path to stdout (in NAR format)"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a edit             -d "open the Nix expression of a Nix package in $EDITOR"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a eval             -d "evaluate a Nix expression"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a hash-file        -d "print cryptographic hash of a regular file"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a hash-path        -d "print cryptographic hash of the NAR serialisation of a path"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a log              -d "show the build log of the specified packages or paths, if available"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a ls-nar           -d "show information about the contents of a NAR file"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a ls-store         -d "show information about a store path"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a optimise-store   -d "replace identical files in the store by hard links"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a path-info        -d "query information about store paths"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a ping-store       -d "test whether a store can be opened"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a repl             -d "start an interactive environment for evaluating Nix expressions"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a run              -d "run a shell in which the specified packages are available"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a search           -d "query available packages"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a show-config      -d "show the Nix configuration"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a show-derivation  -d "show the contents of a store derivation"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a sign-paths       -d "sign the specified paths"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a to-base16        -d "convert a hash to base-16 representation"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a to-base32        -d "convert a hash to base-32 representation"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a to-base64        -d "convert a hash to base-64 representation"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a to-sri           -d "convert a hash to SRI representation"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a upgrade-nix      -d "upgrade Nix to the latest stable version"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a verify           -d "verify the integrity of store paths"
complete -c nix -f -n "not __fish_seen_subcommand_from $nix_commands" -a why-depends      -d "show why a package has another package in its closure"

for cmd in run build
  __nix_complete_subcommand $cmd -l arg -r -d "NAME EXPR argument to be passed to Nix functions"
  __nix_complete_subcommand $cmd -l argstr -r -d "NAME STRING string-valued argument to be passed to Nix functions"
end

__nix_complete_subcommand add-to-store -s n -l name -r -d "name component of the store path"

__nix_complete_subcommand run -a "(__nix_pkg_attr_names)"
__nix_complete_subcommand run -s c -l command -d "command and arguments to be executed; defaults to 'bash'"
__nix_complete_subcommand run -s i -l ignore-environment -d "clear the entire environment (except those specified with --keep)"
__nix_complete_subcommand run -s k -l keep -r -a "(__nix_complete_env)" -d "keep specified environment variable"
__nix_complete_subcommand run -s u -l unset -r -a "(__nix_complete_env)" -d "unset specified environment variable"

__nix_complete_subcommand build -a "(__nix_pkg_attr_names)"
__nix_complete_subcommand build      -l no-link                 -d "do not create a symlink to the build result"
__nix_complete_subcommand build -s o -l out-link -r -F          -d "path of the symlink to the build result"

__nix_complete_subcommand to-base16 -d "convert a hash to base-16 representation"
__nix_complete_subcommand to-base32 -d "convert a hash to base-32 representation"
__nix_complete_subcommand to-base64 -d "convert a hash to base-64 representation"
__nix_complete_subcommand to-sri    -d "convert a hash to SRI representation"

for cmd in build copy copy-sigs dump-path edit eval log path-info run search \
      show-derivation sign-paths verify why-depends
  __nix_complete_subcommand $cmd -s f -l file -r -F -d "evaluate FILE rather than the default"
end

for cmd in build copy copy-sigs dump-path edit eval log path-info run search \
      show-derivation sign-paths verify why-depends repl \
  __nix_complete_subcommand $cmd -s I -l include -r -F -d "add a path to the list of locations used to look up <...> file names"
end

for cmd in to-base16 to-base32 to-base64 to-sri
  __nix_complete_subcommand $cmd -l type -r -f -a "(__nix_hash_types)" -d "hash algorithm"
end

for cmd in add-to-store build upgrade-nix
  __nix_complete_subcommand $cmd -l dry-run -d "show what this command would do without doing it"
end
