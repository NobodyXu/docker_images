verify_docker_install() {
    echo -e "\nVerifing docker install"
    docker run --rm hello-world
    exit_status=$?
    docker rmi hello-world
    if [ $exit_status -ne 0 ]; then
        echo -e "\nDocker is not installed properly, something went wrong"
        exit 1
    fi
}

restart_docker() {
    echo -e "\nRestarting docker"
    /etc/init.d/docker restart
}
