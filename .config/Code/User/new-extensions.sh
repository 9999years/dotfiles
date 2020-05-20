#! /usr/bin/env bash

./list-extensions.sh \
    | diff --color \
        --unchanged-line-format="" \
        --new-line-format="%L" \
        --old-line-format="" \
        extensions.txt -
