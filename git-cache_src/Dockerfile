FROM debian:buster AS base

# This code is adapted from:
#     https://gist.github.com/dergachev/8441335#gistcomment-2007024
ENV DEBIAN_FRONTEND=noninteractive

## When installed using `pat install squid-deb-proxy`, it listens on port 8000 on the host by dfault.
ARG APT_PROXY_PORT=8000
COPY detect-apt-proxy.sh /root
RUN /root/detect-apt-proxy.sh ${APT_PROXY_PORT}

# Install dependencies
RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y nodejs npm git apt-utils
RUN apt-get clean

# Install git-cache-http-server
RUN npm install -g git-cache-http-server

# Workaround the problem that multi-stage build cannot copy files between stages when 
# usernamespace is enabled.
RUN chown -R root:root $(ls / | grep -v -e "dev" -e "sys" -e "tmp" -e "proc") || echo

FROM debian:buster
COPY --from=base / /
EXPOSE 8080
CMD ["/usr/bin/env", "git-cache-http-server"]
