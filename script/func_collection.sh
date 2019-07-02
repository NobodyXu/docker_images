red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

# The first argument will be treated as colour, the second as the text.
colored_output() {
    echo -e "${1}${2}${end}"
}

progress_log() {
    colored_output ${grn} "\n${1}"
}

err_log() {
    colored_output ${red} "\n${1}"
}

verify_docker_install() {
    progress_log "Verifing docker install"

    docker run --rm hello-world
    exit_status=$?

    docker rmi hello-world

    Exit_if_failed $exit_status "\nDocker is not installed properly, something went wrong"

    #if [ $exit_status -ne 0 ]; then
    #    echo -e "\nDocker is not installed properly, something went wrong"
    #    exit 1
    #fi
}

restart_docker() {
    progress_log "Restarting docker"
    /etc/init.d/docker restart
}

# If [ $1 -ne 0 ], print $2 and exit.
Exit_if_failed() {
    if [ $1 -ne 0 ]; then
        err_log "$2"
        exit 1
    fi
}

# eval "$1". If it failed, print $2 and exit.
Eval_and_Exit_if_failed() {
    eval "$1"
    Exit_if_failed $? "$2"
}
