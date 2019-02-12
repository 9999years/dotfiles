# bash... not good...
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while read file; do
	REL="$(abs2rel "$SCRIPT_DIR/$file" "$HOME")"
	DIR="$HOME/$(dirname "$file")"
	echo "$DIR -> $REL"
	ln -s "$REL" "$DIR"
done < linux_dotfiles.txt
