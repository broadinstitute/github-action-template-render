# ARG BASE_TAG=0.0.1

# FROM broadinstitute/github-action-template-render:${BASE_TAG}

ARG BASE_TAG=gomplate

FROM broadinstitute/configurator-base:${BASE_TAG}

COPY base-image/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /working

ENTRYPOINT [ "/entrypoint.sh" ]

