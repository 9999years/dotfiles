function __add_to_path_if_exists -a var \
        --description 'Prepend directories to a path variable if they exist'
    set var_value (eval "echo \"\$$var\"")
    # Skip the first arg ($var) and then iterate in reverse;
    # because we prepend, so it preserves order.
    for dir in $argv[-1..2]
        if test -e $dir && not contains $dir $var_value
            set -gx --path $var $dir $var_value
        end
    end
end
