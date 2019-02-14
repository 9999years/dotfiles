set -gx FISHRC "$HOME/.config/fish/config.fish"
set -gx LS_OPTIONS "--color=auto"
set -gx EDITOR vim

set -gx PATH $HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
set -gx LD_LIBRARY_PATH "$HOME/.local/lib"
set -gx LD_RUN_PATH "$HOME/.local/lib"
set -gx LDFLAGS "-L$HOME/.local/lib"
set -gx CFLAGS "-I$HOME/.local/include"
set -gx MANPATH "$HOME/.local/share/man:$HOME/.local/man:/usr/share/man"

abbr ll 'ls -la'
abbr l. 'ls -A'

abbr xrdb_merge 'xrdb -merge -I$HOME ~/.Xresources'
abbr build_local './configure --prefix="$HOME/.local"; and make; and make install'
abbr diff colordiff
abbr diadem 'ssh guru@diadem.cs.brandeis.edu'
