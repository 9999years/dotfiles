# Defined in /tmp/fish.w25efJ/fish_greeting.fish @ line 2
function fish_greeting
    if test -z "$IN_NIX_SHELL"
        echo -s (set_color --bold blue) "    Hello miss! " (set_color normal) \
                   (set_color green) (uptime) (set_color normal)
    else
        echo -s -n (set_color --bold blue) "🐟  " (set_color normal)
    end
end
