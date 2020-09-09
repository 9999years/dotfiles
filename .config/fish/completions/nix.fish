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

set -l nix_commands \
    add-to-store build cat-nar cat-store copy copy-sigs doctor dump-path edit \
    eval hash-file hash-path log ls-nar ls-store optimise-store path-info \
    ping-store repl run search show-config show-derivation sign-paths \
    to-base16 to-base32 to-base64 to-sri upgrade-nix verify why-depends

set -l nix_options (echo \
  "allow-import-from-derivation                Whether the evaluator allows importing the result of a derivation. \
  allow-new-privileges                        Whether builders can acquire new privileges by calling programs with setuid/setgid bits or with file capabilities. \
  allow-unsafe-native-code-during-evaluation  Whether builtin functions that allow executing native code should be enabled. \
  allowed-impure-host-deps                    Which prefixes to allow derivations to ask for access to (primarily for Darwin). \
  allowed-uris                                Prefixes of URIs that builtin functions such as fetchurl and fetchGit are allowed to fetch. \
  allowed-users                               Which users or groups are allowed to connect to the daemon. \
  auto-optimise-store                         Whether to automatically replace files with identical contents with hard links. \
  build-hook                                  The path of the helper program that executes builds to remote machines. \
  build-poll-interval                         How often (in seconds) to poll for locks. \
  build-users-group                           The Unix group that contains the build users. \
  builders                                    A semicolon-separated list of build machines, in the format of nix.machines. \
  builders-use-substitutes                    Whether build machines should use their own substitutes for obtaining build dependencies if possible, rather than waiting for this host to upload them. \
  compress-build-log                          Whether to compress logs. \
  connect-timeout                             Timeout for connecting to servers during downloads. 0 means use curl's builtin default. \
  cores                                       Number of CPU cores to utilize in parallel within a build, i.e. by passing this number to Make via '-j'. 0 means that the number of actual CPU cores on the local host ought to be auto-detect \ed.
  diff-hook                                   A program that prints out the differences between the two paths specified on its command line. \
  download-attempts                           How often Nix will attempt to download a file before giving up. \
  enforce-determinism                         Whether to fail if repeated builds produce different output. \
  extra-platforms                             Additional platforms that can be built on the local system. These may be supported natively (e.g. armv7 on some aarch64 CPUs or using hacks like qemu-user. \
  extra-sandbox-paths                         Additional paths to make available inside the build sandbox. \
  extra-substituters                          Additional URIs of substituters. \
  fallback                                    Whether to fall back to building when substitution fails. \
  filter-syscalls                             Whether to prevent certain dangerous system calls, such as creation of setuid/setgid files or adding ACLs or extended attributes. Only disable this if you're aware of the security implicat \ions.
  fsync-metadata                              Whether SQLite should use fsync(). \
  gc-check-reachability                       Whether to check if new GC roots can in fact be found by the garbage collector. \
  gc-reserved-space                           Amount of reserved disk space for the garbage collector. \
  hashed-mirrors                              A list of servers used by builtins.fetchurl to fetch files by hash. \
  http-connections                            Number of parallel HTTP connections. \
  http2                                       Whether to enable HTTP/2 support. \
  impersonate-linux-26                        Whether to impersonate a Linux 2.6 machine on newer kernels. \
  keep-build-log                              Whether to store build logs. \
  keep-derivations                            Whether the garbage collector should keep derivers of live paths. \
  keep-env-derivations                        Whether to add derivations as a dependency of user environments (to prevent them from being GCed). \
  keep-failed                                 Whether to keep temporary directories of failed builds. \
  keep-going                                  Whether to keep building derivations when another build fails. \
  keep-outputs                                Whether the garbage collector should keep outputs of live derivations. \
  log-lines                                   If verbose-build is false, the number of lines of the tail of the log to show if a build fails. \
  max-build-log-size                          Maximum number of bytes a builder can write to stdout/stderr before being killed (0 means no limit). \
  max-free                                    Stop deleting garbage when free disk space is above the specified amount. \
  max-jobs                                    Maximum number of parallel build jobs. \"auto\" means use number of cores. \
  max-silent-time                             The maximum time in seconds that a builer can go without producing any output on stdout/stderr before it is killed. 0 means infinity. \
  min-free                                    Automatically run the garbage collector when free disk space drops below the specified amount. \
  min-free-check-interval                     Number of seconds between checking free disk space. \
  narinfo-cache-negative-ttl                  The TTL in seconds for negative lookups in the disk cache i.e binary cache lookups that return an invalid path result \
  narinfo-cache-positive-ttl                  The TTL in seconds for positive lookups in the disk cache i.e binary cache lookups that return a valid path result. \
  netrc-file                                  Path to the netrc file used to obtain usernames/passwords for downloads. \
  plugin-files                                Plugins to dynamically load at nix initialization time. \
  post-build-hook                             A program to run just after each successful build. \
  pre-build-hook                              A program to run just before a build to set derivation-specific build settings. \
  print-missing                               Whether to print what paths need to be built or downloaded. \
  pure-eval                                   Whether to restrict file system and network access to files specified by cryptographic hash. \
  repeat                                      The number of times to repeat a build in order to verify determinism. \
  require-sigs                                Whether to check that any non-content-addressed path added to the Nix store has a valid signature (that is, one signed using a key listed in 'trusted-public-keys'. \
  restrict-eval                               Whether to restrict file system access to paths in \$NIX_PATH, and network access to the URI prefixes listed in 'allowed-uris'. \
  run-diff-hook                               Whether to run the program specified by the diff-hook setting repeated builds produce a different result. Typically used to plug in diffoscope. \
  sandbox                                     Whether to enable sandboxed builds. Can be \"true\", \"false\" or \"relaxed\". \
  sandbox-build-dir                           The build directory inside the sandbox. \
  sandbox-dev-shm-size                        The size of /dev/shm in the build sandbox. \
  sandbox-fallback                            Whether to disable sandboxing when the kernel doesn't allow it. \
  sandbox-paths                               The paths to make available inside the build sandbox. \
  secret-key-files                            Secret keys with which to sign local builds. \
  show-trace                                  Whether to show a stack trace on evaluation errors. \
  stalled-download-timeout                    Timeout (in seconds) for receiving data from servers during download. Nix cancels idle downloads after this timeout's duration. \
  store                                       The default Nix store to use. \
  substitute                                  Whether to use substitutes. \
  substituters                                The URIs of substituters (such as https://cache.nixos.org/). \
  sync-before-registering                     Whether to call sync() before registering a path as valid. \
  system                                      The canonical Nix system name. \
  system-features                             Optional features that this system implements (like \"kvm\"). \
  tarball-ttl                                 How long downloaded files are considered up-to-date. \
  timeout                                     The maximum duration in seconds that a builder can run. 0 means infinity. \
  trace-function-calls                        Emit log messages for each function entry and exit at the 'vomit' log level (-vvvv) \
  trusted-public-keys                         Trusted public keys for secure substitution. \
  trusted-substituters                        Disabled substituters that may be enabled via the substituters option by untrusted users. \
  trusted-users                               Which users or groups are trusted to ask the daemon to do unsafe things. \
  use-case-hack                               Whether to enable a Darwin-specific hack for dealing with file name collisions. \
  use-sqlite-wal                              Whether SQLite should use WAL mode. \
  user-agent-suffix                           String appended to the user agent in HTTP requests."
)

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
complete -c nix       -l option -r              -d "[common] set a Nix configuration option (overriding nix.conf)"

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

complete -c nix -f -n "__fish_seen_subcommand_from add-to-store" -l dry-run -d "show what this command would do without doing it"
complete -c nix -f -n "__fish_seen_subcommand_from add-to-store" -s n -l name -r -d "name component of the store path"

complete -c nix -f -n "__fish_seen_subcommand_from run" -a "(__nix_pkg_attr_names)"
complete -c nix -f -n "__fish_seen_subcommand_from run" -l arg -d "argument to be passed to Nix functions"
complete -c nix -f -n "__fish_seen_subcommand_from run" -l argstr -d "string-valued argument to be passed to Nix functions"
complete -c nix -f -n "__fish_seen_subcommand_from run" -s c -l command -d "command and arguments to be executed; defaults to 'bash'"
complete -c nix -f -n "__fish_seen_subcommand_from run" -s f -l file -r -d "evaluate FILE rather than the default"
complete -c nix -f -n "__fish_seen_subcommand_from run" -s i -l ignore-environment -d "clear the entire environment (except those specified with --keep)"
complete -c nix -f -n "__fish_seen_subcommand_from run" -s k -l keep -r -a "(__nix_complete_env)" -d "keep specified environment variable"
complete -c nix -f -n "__fish_seen_subcommand_from run" -s u -l unset -r -a "(__nix_complete_env)" -d "unset specified environment variable"
