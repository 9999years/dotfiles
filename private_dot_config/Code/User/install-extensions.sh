#! /usr/bin/env bash
exts="--force"
while read -r ext
do
    exts="$exts --install-extension $ext"
done < extensions.txt
code "--extensions-dir=$HOME/.vscode/extensions" $exts
