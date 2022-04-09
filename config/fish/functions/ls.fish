function ls --wraps exa -d 'List files'
    if command -q exa
        exa -l
    else
        ls -l
    end
end
