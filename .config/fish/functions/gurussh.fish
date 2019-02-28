# Defined in /tmp/fish.JA31SJ/gurussh.fish @ line 1
function gurussh -a server -w ssh
	if needs-help
		echo "gurussh SERVER [SSH OPTIONS...]"
		echo "Opens an SSH session for guru@SERVER.cs.brandeis.edu."
		return 1
	end
	ssh $argv[2..-1] guru@$server.cs.brandeis.edu
end
