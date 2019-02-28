#!/bin/bash

# bash... not good...
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while read file; do
	DIR="$(dirname "$HOME/$file")"
	REL="$(abs2rel "$SCRIPT_DIR/$file" "$DIR")"
	DEST="$HOME/$file"
	if [[ ! -w "$DEST" ]]
	then
		echo -e "\e[32m$DEST \t->\t $REL\e[0m"
		ln -s "$REL" "$DIR"
	else
		echo -e "\e[34mSkipping existing file: $DEST\e[0m"
	fi
done < "$SCRIPT_DIR/linux_dotfiles.txt"
