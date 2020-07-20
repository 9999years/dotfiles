function is_wsl --description 'true if the current system is WSL'
    test ! -z "$WSL_DISTRO_NAME"
end
