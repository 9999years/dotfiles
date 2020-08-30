# Defined in /tmp/fish.Ob4vgX/fish_greeting.fish @ line 2
function fish_greeting
    if test -z "$IN_NIX_SHELL"
        echo -s (set_color --bold blue) "    Hello miss! " (set_color normal) \
                   (set_color green) (uptime) (set_color normal)
        if command -vq puppy
            echo -s (set_color magenta) (puppy) (set_color normal)
        end
    else
        echo -s -n (set_color --bold blue) "🐟  " (set_color normal)
    end
end
