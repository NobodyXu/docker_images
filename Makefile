.PHONY: all
all: build-env-base

# Rules for building docker
%: 
	env DOCKER_BUILDKIT=0 docker build "$@_src" --tag="$@"

build-env-base: enable_apt_cache

enable_apt_cache: apt-cache
	./apt-cache_src/run_apt_caching.sh
