# Defined in - @ line 2
function nix-show --argument attr
	bat (nix-env --query --available --json --attr $attr \
| jq --raw-output '.[] | .meta.position' \
| sed 's/:[0-9]\+$//')
end
