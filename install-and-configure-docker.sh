#!/usr/bin/env bash

# Get script_dir (does not work for symlink)
# The script below is adapted from:
#     https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "${script_dir}/func_collection.sh"

Exit_if_failed $UID "Does not have enough permission, please run as root"
#if [ $UID -ne 0 ]; then
#    echo "Does not have enough permission, please run as root"
#    exit 1
#fi

# Get system distro and version
source <(sed -e "s/^/SYSTEM_/g" /etc/os-release)

# Install docker-ce using distro's software manager
if [ $SYSTEM_ID_LIKE = "debian" ] && [ $SYSTEM_ID != "ubuntu" ]; then
    echo -e "\nUninstall old, incompatible version of docker-ce"
    apt remove docker docker-engine docker.io containerd runc

    echo -e "\nInstall necessary softwares for adding docker-ce apt source with gpg key"
    apt update && apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
    Exit_if_failed $? "\nFailed to install the necessary softwares for adding docker-ce apt source with gpg key"

    echo -e "\nInstalling fingerprint for docker-ce source"
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

    echo -e "\nVerifing fingerprint of the key"
    apt-key fingerprint 0EBFCD88 2>/dev/null | grep -q "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"
    Eval_and_Exit_if_failed "[ $? -ne 1 ]" "Failed to verify the fingerprint"
    #if [ $? -eq 1 ]; then
    #    echo "Failed to verify the fingerprint"
    #    exit 1
    #fi

    echo -e "\nAdding docker-ce apt source"
    add-apt-repository "deb https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    Exit_if_failed $? "Failed to add the docker debian source"
    #if [ $? -ne 0 ]; then
    #    echo "Failed to add the docker debian source"
    #    exit 1
    #fi

    echo -e "\nInstalling docker-ce"
    apt update && apt install docker-ce docker-ce-cli containerd.io
    Exit_if_failed $? "Failed to install docker-ce"

    echo -e "\nInstall completed"
else
    echo "Distribution not supported"
    exit 1
fi

verify_docker_install

echo -e "\nStart to configure docker\nEnable usernamespace first"
sysctl >/dev/null 2>&1

Eval_and_Exit_if_failed "[ $? -ne 127 ]" "\nCommand 'sysctl' not found and thus cannot enable user namespace"

#if [ $? -eq 127 ]; then
#    echo -e "\nCommand 'sysctl' not found and thus cannot enable user namespace"
#    exit 1
#fi

sysctl -w kernel.unprivileged_userns_clone=1

echo -e "\nEnabling user remap feature in docker using user namespace"
echo -e '{\n    "userns-remap": "default"\n}'>/etc/docker/daemon.json

restart_docker

echo -e "Verifing the user remap feature"
id dockremap
Exit_if_failed $? "\nDockerd failed to create dockremap user"

#if [ $? -ne 0 ]; then
#    echo -e "\nDockerd failed to create dockremap user"
#    exit 1
#fi

grep dockremap /etc/subuid && grep dockremap /etc/subgid
Exit_if_failed $? "\nDockerd failed to setup user remap feature properly"

#if [ $? -ne 0 ]; then
#    echo -e "\nDockerd failed to setup user remap feature properly"
#    exit 1
#fi

verify_docker_install
