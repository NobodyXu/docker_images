#!/usr/bin/env bash

source ./func_collection.sh

if [ $UID -ne 0 ]; then
    echo "Does not have enough permission, please run as root"
    exit 1
fi

# Install docker-ce using distro's software manager
if grep -q -e "Debian" -e "debian" /etc/*-release; then
    echo -e "\nInstall necessary softwares for adding docker-ce apt source with gpg key"
    apt update && \
    apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

    echo -e "\nInstalling fingerprint for docker-ce source"
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

    echo -e "\nVerifing fingerprint of the key"
    apt-key fingerprint 0EBFCD88 | grep -q "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"
    if [ $? -eq 1 ]; then
        echo "Failed to verify the fingerprint"
        exit 1
    fi

    echo -e "\nAdding docker-ce apt source"
    add-apt-repository "deb https://download.docker.com/linux/debian $(lsb_release -cs) stable"

    echo -e "\nInstalling docker-ce"
    apt update
    apt install docker-ce docker-ce-cli containerd.io

    echo -e "\nInstall completed"
else
    echo "Distribution not supported"
    exit 1
fi

verify_docker_install

echo -e "\nStart to configure docker\nEnable usernamespace first"
sysctl >/dev/null 2>&1
if [ $? -eq 127 ]; then
    echo -e "\nCommand 'sysctl' not found and thus cannot enable user namespace"
    exit 1
fi
sysctl -w kernel.unprivileged_userns_clone=1

echo -e "\nEnabling user remap feature in docker using user namespace"
echo -e '{\n    "userns-remap": "default"\n}'>/etc/docker/daemon.json

restart_docker

echo -e "Verifing the user remap feature"
id dockremap
if [ $? -ne 0 ]; then
    echo -e "\nDockerd failed to create dockremap user"
    exit 1
fi

grep dockremap /etc/subuid && grep dockremap /etc/subgid
if [ $? -ne 0 ]; then
    echo -e "\nDockerd failed to setup user remap feature properly"
    exit 1
fi

verify_docker_install
