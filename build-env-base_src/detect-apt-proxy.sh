#!/bin/bash -ex
# Adapted from
# https://github.com/sameersbn/docker-apt-cacher-ng
# https://gist.github.com/dergachev/8441335

APT_PROXY_PORT=$1
GIT_PROXY_PORT=$2 # Writen by NobodyXu
HOST_IP=$(awk '/^[a-z]+[0-9]+\t00000000/ { printf("%d.%d.%d.%d\n", "0x" substr($3, 7, 2), "0x" substr($3, 5, 2), "0x" substr($3, 3, 2), "0x" substr($3, 1, 2)) }' < /proc/net/route)

if [[ ! -z "$APT_PROXY_PORT" ]] && [[ ! -z "$HOST_IP" ]]; then
    echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
    cat >> /etc/apt/apt.conf.d/01proxy <<EOL
    Acquire::HTTP::Proxy "http://${HOST_IP}:${APT_PROXY_PORT}";
EOL
    cat /etc/apt/apt.conf.d/01proxy
    echo "Using host's apt proxy"
else
    echo "No squid-deb-proxy detected on docker host"
fi

if [[ ! -z "$GIT_PROXY_PORT" ]] && [[ ! -z "$HOST_IP" ]]; then
    git config --global url."http://$HOST_IP:$GIT_PROXY_PORT/".insteadOf https://
fi
