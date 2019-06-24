.PHONY: all
all: r-lang-env build-env-base
r-lang-env: build-env-base

# Rules for building docker
%: ; docker build "$@_src" --tag="$@"
