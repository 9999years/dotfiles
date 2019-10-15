# Defined in /var/folders/zz/zyxvpxvq6csfxvn_n0001mw8000d72/T//fish.Sh4Ycc/git.fish @ line 2
function git
	if command -v hub
        hub $argv
    else
        command git $argv
    end
end
