FROM debian:buster AS base

RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends squid-deb-proxy
RUN apt-get clean

# Workaround the problem that multi-stage build cannot copy files between stages when 
# usernamespace is enabled.
RUN chown -R root:root $(ls / | grep -v -e "dev" -e "sys" -e "tmp" -e "proc") || echo

FROM debian:buster
COPY --from=base / /

EXPOSE 8000
