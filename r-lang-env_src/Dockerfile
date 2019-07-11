FROM build-env-base as base

USER root

# Install R
# ALso install libxml2-dev so that R package 'xml2' can be installed
RUN apk update && apk add R R-dev libxml2-dev --no-cache
# Load configuration file
COPY Rprofile /root/.Rprofile
# Install packages
## Install basic packages required to install other packages
RUN R -e "install.packages('devtools')"

## Install the rest.
## But first, install readxl (part of tidyverse) separately from github, since only the newest can be installed on alpine
RUN R -e "devtools::install_github('tidyverse/readxl')"

RUN  R -e "install.packages(c('tidyverse', 'stingr', 'stringi', 'MASS'))"

# Workaround the problem that multi-stage build cannot copy files between stages when 
# usernamespace is enabled.
RUN chown -R root:root /bin /etc /lib* /opt /root /sbin /var || echo

FROM build-env-base
COPY --from=base / /
