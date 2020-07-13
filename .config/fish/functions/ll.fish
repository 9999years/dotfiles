# Defined in /var/folders/dm/2kd_hgp51qx5v41_4ct5c8tw001d24/T//fish.IX5rqm/ll.fish @ line 2
function ll --description 'List contents of directory using long format'
    if command -v exa > /dev/null
        command exa -la $argv
    else
        command ls -la $argv
    end
end
