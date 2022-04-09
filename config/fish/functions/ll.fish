function ll --wraps exa -d 'List files, including hidden files'
    if command -q exa
        exa -la
    else
        ls -la
    end
end
