#!/usr/bin/env bash

# Get script_dir (does not work for symlink)
# The script below is adapted from:
#     https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
script_dir="$(cd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1 && pwd)"

source "${script_dir}/func_collection.sh"

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

export -f verify_docker_install
# Export its dependencies (functions it called) as well
export -f progress_log err_log colored_output Exit_if_failed

su $1 bash -c verify_docker_install
