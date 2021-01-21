# Defined in /tmp/fish.1aIPfQ/icat.fish @ line 2
function icat --wraps='kitty +icat'
    kitty +icat --align=left $argv
end
