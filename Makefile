.PHONY: all
all: build-env-base

# Rules for building docker
%: 
	env DOCKER_BUILDKIT=0 docker build "$@_src" --tag="$@"

build-env-base: enable_apt_cache enable_git_cache

enable_apt_cache: apt-cache
	./run_cache.sh apt-caching apt-cache 8000 /var/cache/squid-deb-proxy

enable_git_cache: git-cache apt-cache
	./run_cache.sh git-caching git-cache 8080 /var/cache/git
