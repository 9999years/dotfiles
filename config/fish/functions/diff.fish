# Defined in /tmp/fish.z9xkbg/diff.fish @ line 2
function diff --description 'diffs files'
    if isatty stdout; and command -q delta
        for arg in $argv
            switch $arg
                case --normal \
                    -q --brief \
                    -c -C --context{,=\*} \
                    -e --ed \
                    -n --rcs \
                    -y --side-by-side \
                    --line-format{,=\*} \
                    --{old,new,unchanged}-line-format{,=\*}
                    command diff $argv
                    return
            end
        end
        command diff -u $argv | delta
    else
        command diff $argv
    end
end
