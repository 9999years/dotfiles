# Usage: __preserve_orig VAR_NAME
# Saves the contents of $VAR_NAME to the variable $__orig_VAR_NAME.
# If you (for instance) prepend directories to your $PATH in your config.fish, using:
#     __preserve_orig PATH
#     set -gx PATH ... $__orig_PATH
# will not cause you to add more and more directories every time you
#     source ~/.config/fish/config.fish
function __preserve_orig -a var --description 'save $VAR globally to $__orig_VAR'
    if test -z (eval "echo -n \"\$__orig_$var\"")
        set -g __orig_$var (eval "echo -n \"\$$var\"")
    end
end

