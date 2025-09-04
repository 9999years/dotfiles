function gh-fork
    gh fork
    set -l new_trunk (jj config get 'revset-aliases."trunk()"' | sed 's/@origin/@upstream/')
    jj config set --repo 'revset-aliases."trunk()"' $new_trunk
    jj fetch --all-remotes
    jj bookmark track $new_trunk
end
