complete -c head -s c -l bytes -r -f -d "print the first NUM bytes of each file; with the leading '-', print all but the last NUM bytes of each file"
complete -c head -s n -l lines -r -f -d "print the first NUM lines instead of the first 10; with the leading '-', print all but the last NUM lines of each file"
complete -c head -s q -l quiet -d "never print headers giving file names"
complete -c head      -l silent -d "never print headers giving file names"
complete -c head -s v -l verbose -d "always print headers giving file names"
complete -c head -s z -l zero-terminated -d 'line delimiter is NUL, not newline'
complete -c head      -l help -d 'display help and exit'
complete -c head      -l version -d 'output version information and exit'
