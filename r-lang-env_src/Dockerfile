FROM build-env-base as base

USER root

# Install R
# ALso install libxml2-dev so that R package 'xml2' can be installed
RUN apt-get update && apt-get install -y r-base libxml2-dev

# Load configuration file
COPY Rprofile /root/.Rprofile

# Install packages
RUN  R -e "install.packages(c('devtools', 'tidyverse', 'stingr', 'stringi', 'MASS'))"

# Workaround the problem that multi-stage build cannot copy files between stages when 
# usernamespace is enabled.
RUN chown -R root:root $(ls / | grep -v -e "dev" -e "sys" -e "tmp" -e "proc") || echo

FROM build-env-base
COPY --from=base / /
