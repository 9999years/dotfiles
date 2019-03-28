# Defined in /var/folders/zz/zyxvpxvq6csfxvn_n0001mw8000d72/T//fish.jeTQMl/sudo-ssh.fish @ line 1
function sudo-ssh
	if needs-help
		echo "USAGE: $0 [options] host [command]"
		return 1
	end

	sudo bash -c "source ~root/.ssh/ssh-agent-status && /usr/bin/ssh $argv"
end
