function tx -a glob
    set -l processed_glob ./*$glob*.tex
    switch $glob
        case "*.tex"
            set processed_glob ./*$glob
        case "./*"
            set processed_glob $glob*.tex
    end
    echo "Glob expands to:" $processed_glob
    latexmk $processed_glob
end

