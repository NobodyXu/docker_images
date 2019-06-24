.PHONY: all
all: build-env-base

# Rules for building docker
%: ; docker build "$@_src" --tag="$@"
