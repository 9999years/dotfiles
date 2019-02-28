set -gx FISHRC "$HOME/.config/fish/config.fish"
set -gx LS_OPTIONS "--color=auto"
set -gx EDITOR vim
set -gx NODE_PATH "$HOME/.local/lib/node_modules"
set -gx PYTHONSTARTUP "$HOME/.pythonrc"
set -gx GOPATH "$HOME/.go"

set -gx PATH $HOME/.local/bin $HOME/bin /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin
set -gx --path LD_LIBRARY_PATH $HOME/.local/lib $HOME/.local/lib64 /usr/local/lib /usr/local/lib64 /lib64 /usr/lib64
set -gx --path LD_RUN_PATH $HOME/.local/lib $HOME/.local/lib64 /usr/local/lib /usr/local/lib64 /lib64 /usr/lib64
set -gx --path MANPATH $HOME/.local/share/man $HOME/.local/man /usr/share/man
set -gx LDFLAGS "-L$HOME/.local/lib -L$HOME/.local/lib64 -L/usr/local/lib -L/usr/local/lib64 -L/lib64 -L/usr/lib64"
set -gx CFLAGS "-I$HOME/.local/include -I/usr/local/include"

abbr ll 'ls -la'
abbr l. 'ls -A'

abbr xrdb_merge 'xrdb -merge -I$HOME ~/.Xresources'
abbr build_local './configure --prefix="$HOME/.local"; and make; and make install'
abbr diff colordiff
abbr diadem 'ssh guru@diadem.cs.brandeis.edu'
abbr funced 'funced --save'
abbr req 'pip3 install --user -r ./requirements.txt'
abbr pipi 'pip3 install --user'
abbr x 'chmod +x'
