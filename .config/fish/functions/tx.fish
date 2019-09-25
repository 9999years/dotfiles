# Defined in /tmp/fish.0BD3bo/tx.fish @ line 2
function tx --argument glob
	set -l processed_glob ./*$glob*.tex
    if test -z "$glob"
        set processed_glob (fd .tex | fzf)
        echo $processed_glob
    else
        switch $glob
            case "*.tex"
                set processed_glob ./*$glob
            case "./*"
                set processed_glob $glob*.tex
        end
    end
    if test -z $processed_glob
        echo -e "\e[1m\e[31mNo matches found for glob '$glob'.\e[0m"
    else
        echo -e "\e[1m\e[4mlatexmk" $processed_glob "\e[0m"
        latexmk $processed_glob
    end
end
