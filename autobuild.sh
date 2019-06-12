#!/usr/bin/env sh

for each in *; do
    if [ -d "$each" ]; then
        printf "${each}\n"
    fi
done
