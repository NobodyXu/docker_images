#!/usr/bin/env bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: run_cache.sh (will-be)container_name image_name published_port"
    exit 1
fi

# If the container already exists, remove it and start a new one
# in case that the image is updated.
if ! docker ps -a | grep -q "$1"; then
    # Stop the container first if it is running.
    if ! docker ps | grep -q "$1"; then
        docker stop "$1"
    fi
    docker rm "$1"
fi

exec docker run -d --restart on-failure -p "$3":"$3" --name "$1" "$2"
