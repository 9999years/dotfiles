function dnf
    # Pipe searches to `less`
    if isatty stdout && contains search $argv
        command dnf --color=always $argv | less -r
    else
        command dnf $argv
    end
end
