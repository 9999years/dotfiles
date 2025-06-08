function git-diff-diff \
    -d "like git-range-diff but across all commits in a range" \
    -a base rev1 rev2
    diff \
        --label "$base..$rev1" \
        --label "$base..$rev2" \
        (git diff $base $rev1 | psub) \
        (git diff $base $rev2 | psub)
end
