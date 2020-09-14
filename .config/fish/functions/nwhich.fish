# Defined in /tmp/fish.mVbuXG/nwhich.fish @ line 2
function nwhich --description 'Shows the store paths for Nix binaries.'
    if ! set -l cmd_path (command -v $argv)
        echo "Couldn't locate $argv" 1>&2
        return 1
    else if test -h $cmd_path
        readlink $cmd_path
    else
        echo "$cmd_path isn't a symbolic link" 1>&2
        return 2
    end
end
