# Defined in - @ line 2
function nix-query
	if test -z "$__nix_query_file" -o ! -f "$__nix_query_file"
        echo (set_color green)"Caching Nix package list..."(set_color normal)
        set -g __nix_query_file (mktemp -t nix-packages-cache.XXXXXXXXXXXXXXXX)
        nix-env --query --available --no-name --attr-path >"$__nix_query_file"
    end
    fzf --query="$argv" --header="Nix package fuzzy-search" --multi --preview-window=right:wrap --preview='
nix-env --query --available --json --attr {} \
| jq --color-output \
\'.[]
| del(.name, .meta.platforms, .meta.available, .meta.name, .meta.outputsToInstall)
| .meta.license? |= .fullName? + " (" + .spdxId? + "; " + .url? + ")"
| .meta.maintainers? |= (.[]? | .github? + " (" + .name? + ") <" + .email? + ">")
| . += .meta
| del(.meta)\'' <"$__nix_query_file"
end
