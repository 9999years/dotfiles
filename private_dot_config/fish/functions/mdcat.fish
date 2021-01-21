# Defined in /var/folders/dm/2kd_hgp51qx5v41_4ct5c8tw001d24/T//fish.0ewew6/mdcat.fish @ line 1
function mdcat
    if isatty stdout
        command mdcat $argv | less -r
    else
        command mdcat $argv
    end
end
