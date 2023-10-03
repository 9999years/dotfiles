function tide-reconfigure
    tide configure --auto \
        --style=Rainbow \
        --prompt_colors='True color' \
        --show_time='12-hour format' \
        --rainbow_prompt_separators=Vertical \
        --powerline_prompt_heads=Sharp \
        --powerline_prompt_tails=Flat \
        --powerline_prompt_style='Two lines, character' \
        --prompt_connection=Disconnected \
        --powerline_right_prompt_frame=No \
        --prompt_spacing=Compact \
        --icons='Many icons' \
        --transient=Yes

    # Nix logo colors: 8BB6DE 5873BA
    set -U tide_nix_color 8BB6DE
    set -U tide_nix_bg_color black
    set -U tide_nix_icon ' ' # ❆❄
    if ! contains nix $tide_left_prompt_items
        set --prepend tide_left_prompt_items nix
    end
    if set -l index (contains --index nix_shell $tide_right_prompt_items)
        set --erase tide_right_prompt_items[$index]
    end
    # I don't need fancy shapes, and my `normal` bg_color hack above plays poorly
    # with them anyways.
    set -U tide_left_prompt_prefix ''
    set -U tide_left_prompt_suffix ''
    set -U tide_right_prompt_prefix ''
    set -U tide_right_prompt_suffix ''
    set -U tide_character_icon '$'
end
