function __init_fisher --description 'Initialize the fisher plugin manager: https://github.com/jorgebucaran/fisher'
    set -g fisher_path "$HOME/.config/fisher_local"

    if not contains $fisher_path/functions $fish_function_path
        set fish_function_path \
            $fish_function_path[1] \
            $fisher_path/functions \
            $fish_function_path[2..-1]
    end

    if not contains $fisher_path/completions $fish_complete_path
        set fish_complete_path \
            $fish_complete_path[1] \
            $fisher_path/completions \
            $fish_complete_path[2..-1]
    end

    for file in $fisher_path/conf.d/*.fish
        builtin source $file 2> /dev/null
    end
end
