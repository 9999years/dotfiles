# Defined in /tmp/fish.TFyyWX/fish_prompt.fish @ line 2
function fish_prompt --description 'Write out the prompt'
	set -l color_cwd
    set -l suffix
    set -l nix_shell_info (
        if test -n "$IN_NIX_SHELL"
            echo -n -s (set_color cyan) "<nix-shell> " (set_color normal)
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

    echo -n -s "$nix_shell_info" (set_color $color_cwd) (prompt_pwd) (set_color normal) " $suffix "
end
