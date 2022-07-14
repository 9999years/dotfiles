function ssh
    command env SHELL=(command -v bash) ssh $argv
end
