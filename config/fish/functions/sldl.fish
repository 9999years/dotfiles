function sldl --wraps=sldl
    if test $argv[1] = --help
        command sldl $argv
    end

    command \
        sldl \
        --user "$(op read "op://Private/SoulseekQT/username")" \
        --pass "$(op read "op://Private/SoulseekQT/password")" \
        --spotify-id "$(op read "op://Private/spotify.com/OAuth App/Client ID")" \
        --spotify-secret "$(op read "op://Private/spotify.com/OAuth App/Client Secret")" \
        --spotify-token "$(op read "op://Private/spotify.com/OAuth App/Token")" \
        --spotify-refresh "$(op read "op://Private/spotify.com/OAuth App/Refresh token")" \
        $argv
end
