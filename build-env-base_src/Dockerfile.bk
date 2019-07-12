FROM alpine:3.9 AS base

USER root

# vim configuration
COPY vimrc /root/.vimrc
# /bin/sh profile
COPY profile /root/.profile
# ctags configuration
COPY ctags /root/.ctags

# Install dependencies
RUN url="http://dl-cdn.alpinelinux.org/alpine/edge/" &&\
    echo -e "${url}main\n${url}community">/etc/apk/repositories

RUN apk update && apk upgrade --no-cache

RUN apk add less clang build-base perl man vim cmake ctags git findutils htop curl-dev wget libmicrohttpd-dev ca-certificates --no-cache

# Installation of glibc compatible layer
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub &&\
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk &&\
    apk add glibc-2.29-r0.apk

# Configure vim and install basic plugins
RUN cd /root; \
    mkdir -p vimrc.d .vim/pack/git-plugins/start; \
    cd .vim/pack/git-plugins/start; \
    git clone --depth 1 https://github.com/w0rp/ale.git; \
    git clone https://github.com/tpope/vim-fugitive.git; \
    git clone https://github.com/LucHermitte/lh-vim-lib.git; \
    git clone https://github.com/LucHermitte/lh-brackets.git; \
    git clone https://github.com/LucHermitte/VimFold4C.git

# Workaround the problem that multi-stage build cannot copy files between stages when 
# usernamespace is enabled.
RUN chown -R root:root /bin /etc /lib* /opt /root /sbin /var || echo

FROM alpine:3.9
COPY --from=base / /
