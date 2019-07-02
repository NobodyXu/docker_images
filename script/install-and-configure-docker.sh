#!/usr/bin/env bash

# Get script_dir (does not work for symlink)
# The script below is adapted from:
#     https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
script_dir="$(cd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1 && pwd)"

source "${script_dir}/func_collection.sh"

is_accessible() {
    # option -f tells curl to fail silently with no output
    # option -I tells curl to only download the header
    # option -s puts curl in quiet mode, with no progress meter or error message
    curl -fIs "${1}" --output /dev/null
}

Exit_if_failed $UID "Does not have enough permission, please run as root"
#if [ $UID -ne 0 ]; then
#    echo "Does not have enough permission, please run as root"
#    exit 1
#fi

# Get system distro and version
source <(sed -e "s/^/SYSTEM_/g" /etc/os-release)

failed=false
# Install docker-ce using distro's software manager
if [ $SYSTEM_ID_LIKE = "debian" ]; then
    base_url="https://download.docker.com/linux/${SYSTEM_ID}"
    if ! is_accessible "${base_url}/dists/${SYSTEM_VERSION_CODENAME}/stable"; then
	# Try using the distro it is derived from
	# Only works for raspbian
        base_url="https://download.docker.com/linux/${SYSTEM_ID_LIKE}"
        if ! is_accessible "${base_url}/dists/${SYSTEM_VERSION_CODENAME}/stable"; then
            failed=true
        fi
    fi

    if ! $failed; then
        progress_log "Uninstall old, incompatible version of docker-ce"
        apt remove -y docker docker-engine docker.io containerd runc

        progress_log "Install necessary softwares for adding docker-ce apt source with gpg key"
	packages="apt-transport-https ca-certificates curl gnupg2 software-properties-common"
        apt update && apt install -y --no-install-recommends $packages
        Exit_if_failed $? "\nFailed to install the necessary softwares for adding docker-ce apt source with gpg key"

        progress_log "Installing fingerprint for docker-ce source"
        curl -fsSL "${base_url}/gpg" | apt-key add -

        progress_log "Verifing fingerprint of the key"
        apt-key fingerprint 0EBFCD88 2>/dev/null | grep -q "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"
        Eval_and_Exit_if_failed "[ $? -ne 1 ]" "Failed to verify the fingerprint"
        #if [ $? -eq 1 ]; then
        #    echo "Failed to verify the fingerprint"
        #    exit 1
        #fi

        progress_log "Adding docker-ce apt source -- will overwrite /etc/apt/sources.list.d/docker-ce.list"
	repository="${base_url} ${SYSTEM_VERSION_CODENAME} stable"
	echo -e "deb ${repository}\ndeb-src ${repository}">/etc/apt/sources.list.d/docker-ce.list
        Exit_if_failed $? "Failed to add the docker debian source"
        #if [ $? -ne 0 ]; then
        #    echo "Failed to add the docker debian source"
        #    exit 1
        #fi

	progress_log "Installing docker-ce (first removing it)"

        packages="docker-ce docker-ce-cli containerd.io"
        apt remove -y $packages
	apt update && apt install -y --no-install-recommends $packages

        Exit_if_failed $? "Failed to install docker-ce"

        progress_log "Install completed"
    fi
fi

if $failed; then
    progress_log "Fallback to convenience script provided by docker"
    curl -fsSL https://get.docker.com | sh
    Exit_if_failed $? "Failed to install docker-ce by using convenience script provided by docker"
fi

verify_docker_install

progress_log "Start to configure docker\nEnable usernamespace first"
# Check whether usernamespace is enabled.
# Load a module first
modprobe configs

# Register a callback for unloading this module
trap "rmmod configs" EXIT
if ! zgrep -E "CONFIG_USER_NS=y" >/dev/null 2>&1; then
    msg="Please install a kernel configured with usernamepsace enabled as raspbian disallow enable it dynamically!"
    Exit_if_failed "[ $SYSTEM_ID != 'raspbian' ]" $msg

    sysctl >/dev/null 2>&1
    Eval_and_Exit_if_failed "[ $? -ne 127 ]" "\nCommand 'sysctl' not found and thus cannot enable user namespace"

    sysctl -w kernel.unprivileged_userns_clone=1
    
    #if [ $? -eq 127 ]; then
    #    echo -e "\nCommand 'sysctl' not found and thus cannot enable user namespace"
    #    exit 1
    #fi
fi

progress_log "Enabling user remap feature in docker using user namespace"
echo -e '{\n    "userns-remap": "default"\n}'>/etc/docker/daemon.json

restart_docker

progress_log "Verifing the user remap feature"
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
