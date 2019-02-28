# Defined in /tmp/fish.67AhPr/merge.fish @ line 2
function merge --argument src dest
	pushd "$dest"
	set dest (pwd)
	popd
	pushd "$src"
	echo "Merging files from" (pwd) "into $dest"
	find -type f -exec install -vD '{}' "$dest/{}" \;
	popd
end
