# Defined in - @ line 1
function xrestart --description 'Restarts the X server'
	sudo systemctl restart display-manager.service $argv
end
