# Defined in /tmp/fish.eUb1dr/edit-terminal-settings.fish @ line 2
function edit-terminal-settings
	set -l app "Microsoft.WindowsTerminal_8wekyb3d8bbwe"
    set -l basename "profiles.json"
    set -l settings (wslpath "C:/Users/$USER/AppData/Local/Packages/$app/LocalState/$basename")
    echo Opening $settings
    env "$EDITOR" "$settings"
end
