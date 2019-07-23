# syntax=docker/dockerfile:experimental
FROM debian:buster AS base

USER root

# /bin/sh profile
COPY profile /root/.profile

# Add apt cache
# This code is adapted from:
#     https://gist.github.com/dergachev/8441335#gistcomment-2007024
ENV DEBIAN_FRONTEND=noninteractive

## When installed using `apt install squid-deb-proxy`, it listens on port 8000 on the host by dfault.
ARG APT_PROXY_PORT=8000
ARG GIT_PROXY_PORT=8080

COPY detect-apt-proxy.sh /root
RUN /root/detect-apt-proxy.sh ${APT_PROXY_PORT}

RUN apt-get update && apt-get dist-upgrade -y

# Install basic softwares
RUN apt-get install -y less build-essential perl cmake git findutils curl wget ca-certificates \
                       automake autoconf apt-utils

# Add git proxy 
RUN /root/detect-apt-proxy.sh "" ${GIT_PROXY_PORT}

# Install llvm softwares
## First install dependencies for building clang
RUN apt-get install -y python libncurses5-dev libedit-dev libpthread-stubs0-dev

## Also clang for self lifting
RUN apt-get install -y clang

## Clone repository for auto building llvm
RUN git clone https://github.com/rsmmr/install-clang.git /tmp/install-clang

COPY run_install_clang.sh /root/
RUN env -u CFLAGS -u LDFLAGS PATH=/opt/clang/bin:$PATH /root/run_install_clang.sh

## Install R
## ALso install libxml2-dev so that R package 'xml2' can be installed
#RUN apt-get update && apt-get install -y r-base libxml2-dev
#
## Load configuration file
#COPY Rprofile /root/.Rprofile
#
## Install packages
#RUN  R -e "install.packages(c('devtools', 'tidyverse', 'stingr', 'stringi', 'MASS'))"

# Upgrade all packages in case of cache invalidation of layers
RUN apt-get dist-upgrade -y

# Clean apt-get cache and rsmmr git repo in /tmp
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Workaround the problem that multi-stage build cannot copy files between stages when 
# usernamespace is enabled.
RUN chown -R root:root $(ls / | grep -v -e "dev" -e "sys" -e "tmp" -e "proc") || echo

FROM debian:buster
COPY --from=base / /
