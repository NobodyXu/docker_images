.PHONY: all
all: build-env-base

# Rules for building docker
%: ; env DOCKER_BUILDKIT=0 docker build "$@_src" --tag="$@"
