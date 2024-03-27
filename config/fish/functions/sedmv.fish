function sedmv --description "Move a path by modifying its name with `sed`"
    argparse \
        --min-args 3 \
        h/help \
        1/once \
        n/dry-run \
        b/backup \
        i/interactive \
        f/force \
        -- $argv
    or return

    if set -ql _flag_help
        echo "sedmv [OPTIONS] FIND REPLACE [PATH ...]"
        echo
        echo "Options:"
        echo "    -h  --help        Display help and exit"
        echo "    -1  --once        Only replace one match of FIND with REPLACE in each path"
        echo "    -n  --dry-run     Print renames that would be performed"
        echo "    -b  --backup      Use `mv --backup`"
        echo "    -i  --interactive Use `mv --interactive`"
        echo "    -f  --force       Don't use `mv --no-clobber`"
        return 0
    end

    set -l find $argv[1]
    set -l replace $argv[2]
    set -l paths $argv[3..]

    set -l sedReplace "s`$find`$replace`"
    if not set -ql _flag_once
        set sedReplace "$sedReplace"g
    end

    set -l mvOptions --no-clobber

    if set -ql _flag_force
        set mvOptions
    end

    if set -ql _flag_backup
        set --append mvOptions --backup
    end

    if set -ql _flag_interactive
        set --append mvOptions --interactive
    end

    for path in $paths
        set --local newPath (echo "$path" | sed -E "$sedReplace")
        if set -ql _flag_dry_run
            echo mv $mvOptions "$path" "$newPath"
        else
            mv $mvOptions "$path" "$newPath"
        end
    end
end
