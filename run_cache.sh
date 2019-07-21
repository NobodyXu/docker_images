#!/usr/bin/env bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: run_cache.sh (will-be)container_name image_name"
fi

if ! docker ps -a | grep -q "$1"; then
    docker run -d --restart on-failure --name $1 $2
elif ! docker ps | grep -q "$1"; then
fi
