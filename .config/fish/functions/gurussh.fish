# Defined in /tmp/fish.uQytku/gurussh.fish @ line 2
function gurussh --argument server
	if needs-help
		echo "gurussh SERVER [SSH OPTIONS...]"
		echo "Opens an SSH session for guru@SERVER.cs.brandeis.edu."
		return 1
	end
	ssh $argv[2..-1] guru@$server.cs.brandeis.edu
end
