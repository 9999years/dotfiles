# Defined in /tmp/fish.pdvYG5/nsearch.fish @ line 2
function nsearch --wraps='nix search'
    nix search --json $argv \
        | jq -r "to_entries \
            | .[] \
            | \""(set_color --bold green)"\(.key)"(set_color normal)" \" \
                + \""(set_color --dim white)"\" \
                + \"(\(.value.pkgName)-\(.value.version))\" \
                + \""(set_color normal)": \(.value.description)\""
end
