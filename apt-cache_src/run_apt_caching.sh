#!/usr/bin/env bash

if ! docker ps -a | grep -q "apt-caching"; then
    docker run -d --restart on-failure --name apt-caching apt-cache
elif ! docker ps | grep -q "apt-caching"; then
    docker start apt-caching
fi
