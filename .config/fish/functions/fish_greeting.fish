# Defined in /tmp/fish.Y0xWHf/fish_greeting.fish @ line 2
function fish_greeting
    if test -z "$IN_NIX_SHELL"
        echo -s (set_color --bold blue) "    Hello miss! " (set_color normal) \
                   (set_color green) (uptime) (set_color normal)
        if command -vq puppy
            set_color magenta
            and puppy
            and set_color normal
        end
    else
        echo -s -n (set_color --bold blue) "🐟  " (set_color normal)
    end
end
