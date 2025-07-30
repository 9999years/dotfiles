function sldl --wraps=sldl
    if test $argv[1] = --help || contains --print $argv
        # No secrets needed and 1Password takes time to fetch them, so skip it.
        command sldl $argv
        return
    end

    command \
        sldl \
        --user "$(op read "op://Private/Soulseek/username")" \
        --pass "$(op read "op://Private/Soulseek/password")" \
        --spotify-id "$(op read "op://Private/spotify.com/OAuth App/Client ID")" \
        --spotify-secret "$(op read "op://Private/spotify.com/OAuth App/Client Secret")" \
        --spotify-refresh "$(op read "op://Private/spotify.com/OAuth App/Refresh token")" \
        $argv
end
