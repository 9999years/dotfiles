function __less_init
    set -l end (printf "\e[0m")
    # blink: bold bright red
    set -gx LESS_TERMCAP_mb (set_color --bold brred)
    # bold: bold light blue
    set -gx LESS_TERMCAP_md (set_color --bold 5fafd7)
    set -gx LESS_TERMCAP_me $end
    # standout: black on light yellow
    # Used for search highlights, etc.
    set -gx LESS_TERMCAP_so (set_color --reverse --bold ffdb4d)
    set -gx LESS_TERMCAP_se $end
    # underline: underlined light green
    set -gx LESS_TERMCAP_us (set_color --underline 9eff96)
    set -gx LESS_TERMCAP_ue $end
end
