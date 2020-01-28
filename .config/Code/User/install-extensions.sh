#! /usr/bin/env bash
exts="--force"
while read ext
do
    exts="$exts --install-extension $ext"
done < extensions.txt
code $exts