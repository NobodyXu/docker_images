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
    echo -e "${url}main\n${url}community">/etc/apk/repositories; \
    apk update && apk upgrade --no-cache &&\
    apk add less clang build-base perl man vim cmake ctags git findutils htop curl-dev wget libmicrohttpd-dev --no-cache

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
