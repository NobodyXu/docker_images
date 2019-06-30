verify_docker_install() {
    echo -e "\nVerifing docker install"

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
    echo -e "\nRestarting docker"
    /etc/init.d/docker restart
}

# If [ $1 -ne 0 ], print $2 and exit.
Exit_if_failed() {
    if [ $1 -ne 0 ]; then
        echo -e "$2"
        exit 1
    fi
}

# eval "$1". If it failed, print $2 and exit.
Eval_and_Exit_if_failed() {
    eval "$1"
    Exit_if_failed $? "$2"
}
