# Defined in /tmp/fish.PRz4fz/fish_prompt.fish @ line 2
function fish_prompt --description 'Write out the prompt'
    set -l last_status "$status"
    set -l status_display (
        if test "$last_status" != 0
            echo -n (set_color yellow)"[$last_status] "(set_color normal)
        end
    )

    set -l color_cwd
    set -l suffix
    set -l nix_shell_info (
        if test -n "$IN_NIX_SHELL"
            echo -n (set_color cyan)"[❄ "
            if test -n "$NIX_SHELL_DEPTH" -a "$NIX_SHELL_DEPTH" != 1
                echo -n (set_color --bold)"$NIX_SHELL_DEPTH"(set_color normal)
            end
            echo -n (set_color cyan)"] "(set_color normal)
        end
    )

    switch "$USER"
        case root toor
            if set -q fish_color_cwd_root
                set color_cwd $fish_color_cwd_root
            else
                set color_cwd $fish_color_cwd
            end
            set suffix '#'
        case '*'
            set color_cwd $fish_color_cwd
            set suffix ';'
    end

    echo -sn "$nix_shell_info" "$status_display" \
        "$USER@$hostname " \
        (set_color $color_cwd) \
        (if test "$__prompt_last_dir" != (pwd)
            set -g __prompt_last_dir (pwd)
            prompt_pwd
            echo -n " "
        end) (set_color normal) "$suffix "
end
