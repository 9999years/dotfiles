if command -q beet
    beet fish -o /dev/stdout 2>/dev/null | source
end
