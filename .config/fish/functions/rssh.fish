# Defined in /var/folders/zz/zyxvpxvq6csfxvn_n0001mw8000d72/T//fish.rBlQCS/rssh.fish @ line 1
function rssh --argument server
	if needs-help
		echo "rssh SERVER [SSH OPTIONS...]"
		echo "Opens an SSH session for rebeccaturner@SERVER.cs.brandeis.edu."
		return 1
	end
	ssh $argv[2..-1] rebeccaturner@$server.cs.brandeis.edu
end
