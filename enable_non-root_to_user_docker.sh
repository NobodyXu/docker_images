#!/usr/bin/env sh

source ./func_collection.sh

user="$1"
if [ -z "$user" ]; then
    echo -e "Usage: ./enable_non-root_user_of_docker.sh username"
    exit 1
fi
if [ $UID != 0 ]; then
    echo "Must run as root!"
    exit 1
fi

groupadd docker
usermod -aG docker $user

verify_docker_install
