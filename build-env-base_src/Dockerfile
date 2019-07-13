FROM debian:buster AS base

USER root

# vim configuration
COPY vimrc /root/.vimrc
# /bin/sh profile
COPY profile /root/.profile
# ctags configuration
COPY ctags /root/.ctags

# This code is adapted from:
#     https://gist.github.com/dergachev/8441335#gistcomment-2007024
ENV DEBIAN_FRONTEND=noninteractive

## When installed using `pat install squid-deb-proxy`, it listens on port 8000 on the host by dfault.
ARG APT_PROXY_PORT=8000
COPY detect-apt-proxy.sh /root
RUN /root/detect-apt-proxy.sh ${APT_PROXY_PORT}

RUN apt-get update && apt-get dist-upgrade

RUN apt-get install -y less clang build-essential perl cmake ctags git findutils htop curl wget libmicrohttpd-dev ca-certificates automake autoconf

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
RUN chown -R root:root $(ls / | grep -v -e "dev" -e "sys" -e "tmp" -e "proc") || echo

FROM debian:buster
COPY --from=base / /
