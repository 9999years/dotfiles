function fraktur-wezterm-ssh --description 'SSH into `fraktur` in a new Wezterm window'
    # This needs two PRs.
    #
    # The `--assume-shell` argument was added here:
    # https://github.com/wezterm/wezterm/pull/7379
    #
    # To actually login with `fish`, we need this:
    # RemoteSshDomain: Use `sh -c`, not `$SHELL -c`
    # https://github.com/wezterm/wezterm/pull/7378
    wezterm ssh --assume-shell posix wiggles@fraktur &
    disown
end
