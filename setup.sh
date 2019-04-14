#!/bin/bash
set -e

# bash... not good...
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ! command -v abs2rel
then
	echo "Downloading 'abs2rel' locally"
	wget "https://raw.githubusercontent.com/9999years/abs2rel/master/abs2rel.py" \
		-O ./abs2rel
	chmod +x ./abs2rel
	ABS2REL="$(pwd)/abs2rel"
else
	ABS2REL="$(command -v abs2rel)"
fi

while read -r file; do
	DIR="$(dirname "$HOME/$file")"
	REL="$("$ABS2REL" "$SCRIPT_DIR/$file" "$DIR")"
	DEST="$HOME/$file"
	if [[ ! -w "$DEST" ]]
	then
		echo -e "\e[32m$DEST \t->\t $REL\e[0m"
		ln -s "$REL" "$DIR"
	else
		echo -e "\e[34mSkipping existing file: $DEST\e[0m"
	fi
done < "$SCRIPT_DIR/linux_dotfiles.txt"
