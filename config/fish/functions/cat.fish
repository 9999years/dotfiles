# Defined in /tmp/fish.MXQeQ6/cat.fish @ line 2
function cat
    if test -d $argv[-1]
        if command -v exa > /dev/null
            command exa -la $argv
        else
            command ls -la $argv
        end
    else
        if command -v bat > /dev/null
            command bat $argv
        else
            command cat $argv
        end
    end
end
