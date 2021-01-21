# Defined in /tmp/fish.MXQeQ6/cat.fish @ line 2
function cat
	if command -v bat > /dev/null
        command bat $argv
    else
        command cat $argv
    end
end
