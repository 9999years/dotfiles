#! /usr/bin/env bash

./list-extensions.sh \
    | diff --color \
        --unchanged-line-format="" \
        --new-line-format="newly installed:  %c'\033'[31m%L%c'\033'[0m" \
        --old-line-format="not installed:    %c'\033'[32m%L%c'\033'[0m" \
        extensions.txt -
