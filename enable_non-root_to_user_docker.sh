#!/usr/bin/env bash

source ./func_collection.sh

user="$1"
Eval_and_Exit_if_failed "[ -n '$user' ]" "Usage: ./enable_non-root_user_of_docker.sh username"
#if [ -z "$user" ]; then
#    echo -e "Usage: ./enable_non-root_user_of_docker.sh username"
#    exit 1
#fi

Exit_if_failed $UID "Must run as root!"
#if [ $UID -ne 0 ]; then
#    echo "Must run as root!"
#    exit 1
#fi

groupadd docker
usermod -aG docker $user

verify_docker_install
