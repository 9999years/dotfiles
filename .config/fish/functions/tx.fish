# Defined in /tmp/fish.EoWC6A/tx.fish @ line 2
function tx --argument glob
	set -l processed_glob ""
    if test -z "$glob"
        set glob "(files given by fzf)"
        # No glob given in arguments; use fzf
        set processed_glob (fd .tex | fzf)
    else
        # Use partial glob from arguments
        switch $glob
            case "*.tex"
                set processed_glob ./*$glob
            case "./*"
                set processed_glob $glob*.tex
            case "*"
                set processed_glob ./*$glob*.tex
        end
    end

    if test -z "$glob"
        echo -e "\e[1m\e[31mSearch pattern cannot be empty.\e[0m"
        return 1
    else if test -z $processed_glob
        echo -e "\e[1m\e[31mNo matches found for glob '$glob'.\e[0m"
        return 1
    else
        echo -e "\e[1m\e[4mlatexmk" $processed_glob"\e[0m"
        latexmk $processed_glob
    end
end
