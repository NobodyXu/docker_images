FROM build-env-base as base

USER root

# Install R
RUN apk update && apk add R R-dev --no-cache
# Load configuration file
COPY Rprofile /root/.Rprofile
# Install packages
RUN  R -e "install.packages(c('tidyverse', 'stingr', 'stringi', 'MASS'))"

# Workaround the problem that multi-stage build cannot copy files between stages when 
# usernamespace is enabled.
RUN chown -R root:root /bin /etc /lib* /opt /root /sbin /var || echo

FROM build-env-base
COPY --from=base / /
