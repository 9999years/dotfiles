function __preserve_origs --description '__preserve_orig for multiple variables at a time'
    for var in $argv
        __preserve_orig "$var"
    end
end
