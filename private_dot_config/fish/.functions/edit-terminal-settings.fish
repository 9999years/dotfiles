# Defined in /tmp/fish.9paiDF/edit-terminal-settings.fish @ line 2
function edit-terminal-settings
    if not command -q wslpath
        echo "wslpath not found; not trying to open Windows Terminal settings"
        return 1
    end
    set -l app "Microsoft.WindowsTerminal_8wekyb3d8bbwe"
    set -l basename "profiles.json"
    set -l settings (wslpath "C:/Users/$USER/AppData/Local/Packages/$app/LocalState/$basename")
    echo Opening $settings
    env "$EDITOR" "$settings"
end
