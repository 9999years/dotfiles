# Defined in /var/folders/zz/zyxvpxvq6csfxvn_n0001mw8000d72/T//fish.sIYNgN/defaults-diff.fish @ line 2
function defaults-diff
	set before (mktemp)
	defaults read > "$before"
	read -P "Make a preference change, then press enter"
	colordiff "$before" (defaults read | psub) 2>/dev/null
end
