#!/usr/bin/env sh

for each in *; do
    if [ -d "$each" ] && [ -e "${each}/Dockerfile" ]; then
        docker build "${each}/" --tag="${each}"
    fi
done
