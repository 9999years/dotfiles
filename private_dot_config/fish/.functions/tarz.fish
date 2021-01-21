# Defined in /tmp/fish.TMHAeQ/tarz.fish @ line 1
function tarz --argument dir
	set base (basename "$dir")
	tar -cJf "$base.tar.xz" "$dir"
end
