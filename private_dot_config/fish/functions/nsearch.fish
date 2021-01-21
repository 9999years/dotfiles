# Defined in /tmp/fish.fFgYiw/nsearch.fish @ line 2
function nsearch --wraps='nix search'
    set -l green ""
    set -l normal ""
    set -l gray ""
    if isatty stdout
        set green (set_color --bold green)
        set normal (set_color normal)
        set gray (set_color --dim white)
    end
    nix search --json '^nixos' $argv \
        | jq -r "to_entries \
            | .[] \
            | \"$green\(.key)$normal \" \
                + \"$gray(\(.value.pkgName)-\(.value.version))$normal: \(.value.description)\" \
        "
end
