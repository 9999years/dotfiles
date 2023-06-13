function tail-lsp-logs
    tail -f ~/.local/state/nvim/lsp.log | while read --local --line line
        printf (string trim -c '"' (echo $line | cut -f5))
    end
end
