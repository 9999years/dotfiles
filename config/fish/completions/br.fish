complete -c br -n "__fish_use_subcommand" -l outcmd -d 'Where to write the produced cmd (if any)'
complete -c br -n "__fish_use_subcommand" -s c -l cmd -d 'Semicolon separated commands to execute'
complete -c br -n "__fish_use_subcommand" -l color -d 'Whether to have styles and colors (auto is default and usually OK)' -r -f -a "yes no auto"
complete -c br -n "__fish_use_subcommand" -l conf -d 'Semicolon separated paths to specific config files'
complete -c br -n "__fish_use_subcommand" -l height -d 'Height (if you don\'t want to fill the screen or for file export)'
complete -c br -n "__fish_use_subcommand" -s o -l out -d 'Where to write the produced path (if any)'
complete -c br -n "__fish_use_subcommand" -l set-install-state -d 'Set the installation state (for use in install script)' -r -f -a "undefined refused installed"
complete -c br -n "__fish_use_subcommand" -l print-shell-function -d 'Print to stdout the br function for a given shell'
complete -c br -n "__fish_use_subcommand" -s d -l dates -d 'Show the last modified date of files and directories'
complete -c br -n "__fish_use_subcommand" -s D -l no-dates -d 'Don\'t show last modified date'
complete -c br -n "__fish_use_subcommand" -s f -l only-folders -d 'Only show folders'
complete -c br -n "__fish_use_subcommand" -s F -l no-only-folders -d 'Show folders and files alike'
complete -c br -n "__fish_use_subcommand" -l show-root-fs -d 'Show filesystem info on top'
complete -c br -n "__fish_use_subcommand" -s g -l show-git-info -d 'Show git statuses on files and stats on repo'
complete -c br -n "__fish_use_subcommand" -s G -l no-show-git-info -d 'Don\'t show git statuses on files'
complete -c br -n "__fish_use_subcommand" -l git-status -d 'Only show files having an interesting git status, including hidden ones'
complete -c br -n "__fish_use_subcommand" -s h -l hidden -d 'Show hidden files'
complete -c br -n "__fish_use_subcommand" -s H -l no-hidden -d 'Don\'t show hidden files'
complete -c br -n "__fish_use_subcommand" -s i -l show-gitignored -d 'Show files which should be ignored according to git'
complete -c br -n "__fish_use_subcommand" -s I -l no-show-gitignored -d 'Don\'t show gitignored files'
complete -c br -n "__fish_use_subcommand" -s p -l permissions -d 'Show permissions, with owner and group'
complete -c br -n "__fish_use_subcommand" -s P -l no-permissions -d 'Don\'t show permissions'
complete -c br -n "__fish_use_subcommand" -s s -l sizes -d 'Show the size of files and directories'
complete -c br -n "__fish_use_subcommand" -s S -l no-sizes -d 'Don\'t show sizes'
complete -c br -n "__fish_use_subcommand" -l sort-by-count -d 'Sort by count (only show one level of the tree)'
complete -c br -n "__fish_use_subcommand" -l sort-by-date -d 'Sort by date (only show one level of the tree)'
complete -c br -n "__fish_use_subcommand" -l sort-by-size -d 'Sort by size (only show one level of the tree)'
complete -c br -n "__fish_use_subcommand" -s w -l whale-spotting -d 'Sort by size, show ignored and hidden files'
complete -c br -n "__fish_use_subcommand" -l no-sort -d 'Don\'t sort'
complete -c br -n "__fish_use_subcommand" -s t -l trim-root -d 'Trim the root too and don\'t show a scrollbar'
complete -c br -n "__fish_use_subcommand" -s T -l no-trim-root -d 'Don\'t trim the root level, show a scrollbar'
complete -c br -n "__fish_use_subcommand" -l install -d 'Install or reinstall the br shell function'
complete -c br -n "__fish_use_subcommand" -l no-style -d 'Whether to remove all style and colors from exported tree'
complete -c br -n "__fish_use_subcommand" -l help -d 'Prints help information'
complete -c br -n "__fish_use_subcommand" -s V -l version -d 'Prints version information'
