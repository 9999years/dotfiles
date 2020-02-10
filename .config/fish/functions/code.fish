# Defined in - @ line 2
function code
	if test (count $argv) = 0
        command code --new-window --folder-uri (pwd)
    else
        command code $argv
    end
end
