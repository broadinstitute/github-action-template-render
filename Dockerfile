ARG BASE_TAG=gomplate
# ARG CONFIG_DIR=.

FROM broadinstitute/configurator-base:${BASE_TAG}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /working

ENTRYPOINT [ "/entrypoint.sh" ]
