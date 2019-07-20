# syntax=docker/dockerfile:experimental
FROM debian:buster AS base

USER root

# /bin/sh profile
COPY profile /root/.profile
# ctags configuration
COPY ctags /root/.ctags
# neovim configuration
RUN mkdir /root/.config /root/.config/nvim
COPY init.vim /root/.config/nvim/init.vim

# This code is adapted from:
#     https://gist.github.com/dergachev/8441335#gistcomment-2007024
ENV DEBIAN_FRONTEND=noninteractive

## When installed using `pat install squid-deb-proxy`, it listens on port 8000 on the host by dfault.
ARG APT_PROXY_PORT=8000
COPY detect-apt-proxy.sh /root
RUN /root/detect-apt-proxy.sh ${APT_PROXY_PORT}

RUN apt-get update && apt-get dist-upgrade -y

# Install basic softwares
RUN apt-get install -y less build-essential perl cmake ctags git findutils htop curl wget libmicrohttpd-dev ca-certificates \
                       automake autoconf apt-utils

# Install llvm softwares
## First install dependencies for building clang
RUN apt-get install -y python libncurses5-dev libedit-dev libpthread-stubs0-dev

## Also clang for self lifting
RUN apt-get install -y clang

## Clone repository for auto building llvm
RUN git clone https://github.com/rsmmr/install-clang.git /tmp/install-clang

RUN env -u CFLAGS -u LDFLAGS PATH=/opt/clang/bin:$PATH /tmp/install-clang/install-clang -j $(nproc) -C /opt/clang

## Install R
## ALso install libxml2-dev so that R package 'xml2' can be installed
#RUN apt-get update && apt-get install -y r-base libxml2-dev
#
## Load configuration file
#COPY Rprofile /root/.Rprofile
#
## Install packages
#RUN  R -e "install.packages(c('devtools', 'tidyverse', 'stingr', 'stringi', 'MASS'))"

# Install editor
RUN apt-get install -y neovim

# vim configuration
COPY vimrc /root/.vimrc

# Configure neovim and install basic plugins
RUN cd /root && mkdir -p vimrc.d .vim/pack/git-plugins/start

RUN cd .vim/pack/git-plugins/start && git clone --depth 1 https://github.com/w0rp/ale.git
RUN cd .vim/pack/git-plugins/start && git clone https://github.com/tpope/vim-fugitive.git
RUN cd .vim/pack/git-plugins/start && git clone https://github.com/LucHermitte/lh-vim-lib.git
RUN cd .vim/pack/git-plugins/start && git clone https://github.com/LucHermitte/lh-brackets.git
RUN cd .vim/pack/git-plugins/start && git clone https://github.com/LucHermitte/VimFold4C.git

# Upgrade all packages in case of cache invalidation of layers
RUN apt-get dist-upgrade -y

# Workaround the problem that multi-stage build cannot copy files between stages when 
# usernamespace is enabled.
RUN chown -R root:root $(ls / | grep -v -e "dev" -e "sys" -e "tmp" -e "proc") || echo

FROM debian:buster
COPY --from=base / /
