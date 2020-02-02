# Defined in - @ line 1
function nwhich --description 'Shows the store paths for Nix binaries.'
	readlink (command -v $argv)
end
