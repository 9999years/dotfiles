function fish_greeting
    if test -n "$IN_NIX_SHELL" # Don't show in Nix shells.
        return
    end

    switch (date +%H)
        case 00 01 02 # midnight-2am
            echo -sn (set_color --bold yellow) "Time for bed, puppy! 🛌  "
        case 03 04 05 06 # 3am-6am
            echo -sn (set_color --bold red) "Please go to sleep immediately, puppy! 🛑 💤 😠  "
        case 13 14 15 16 17 # 1pm-5pm
            echo -sn (set_color --bold green) "Good afternoon, miss! 🌞  "
        case 18 19 # 6pm-7pm
            echo -sn (set_color --bold magenta) "Good evening, miss! 🌇  "
        case 20 21 22 # 8pm-10pm
            echo -sn (set_color --bold blue) "Feeling sleepy, puppy? 😴  "
        case 23 24 # 11pm-midnight
            echo -sn (set_color --bold blue) "Go brush your teeth, puppy! 🪥 ❤  "
        case '*' # nominally 7am-noon
            echo -sn (set_color --bold cyan) "Good morning, puppy! 🌄  "
    end

    echo -s (set_color normal)(set_color green)"It's "(date '+%l:%M %P')". " \
        (uptime | tail -c +12)(set_color normal)
end
