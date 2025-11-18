function fraktur-luks-unlock
    op read "op://Mercury/fraktur LUKS2 passphrase/password" \
        | ssh fraktur-locked systemd-tty-ask-password-agent --query
end
