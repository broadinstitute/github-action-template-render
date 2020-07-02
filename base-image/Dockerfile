ARG ALPINE_TAG=3.7

FROM alpine:${ALPINE_TAG}

ENV VAULT_VERSION=1.3.2 \
    LEGACY_CONSUL_TEMPLATE_VERSION=0.13.0 \
    CONSUL_TEMPLATE_VERSION=0.24.1 \
    USE_LEGACY=true \
    CLOUDSDK_PYTHON_SITEPACKAGES=1

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk update && \
    apk add bash py-pip \
    ca-certificates \
    curl \
    jq \
    openssl \
    python \
    util-linux \
    vim \
    wget \
    gomplate \
    git && \
    pip --disable-pip-version-check install yq && \
    wget --no-check-certificate --quiet https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O /tmp/vault_${VAULT_VERSION}_linux_amd64.zip && \
    wget --no-check-certificate --quiet https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -O /tmp/consul_template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    wget --no-check-certificate --quiet https://releases.hashicorp.com/consul-template/${LEGACY_CONSUL_TEMPLATE_VERSION}/consul-template_${LEGACY_CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -O /tmp/consul_template_${LEGACY_CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    wget --quiet https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip -O /tmp/google-cloud-sdk.zip && \
    cd /tmp && \
    unzip -q consul_template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mv consul-template consul-template-latest && \
    unzip -q vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip -q consul_template_${LEGACY_CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mv consul-template consul-template-legacy && \
    mv consul-template-latest consul-template-legacy vault /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/* && \
    cd /usr/local && unzip -q /tmp/google-cloud-sdk.zip && \
    google-cloud-sdk/install.sh --usage-reporting=false --path-update=true --bash-completion=true && \
    google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

COPY Dockerfile /
COPY entrypoint.sh /entrypoint.sh
COPY consul-template.sh /usr/local/bin/consul-template
COPY config.json /etc/consul-template/config/config.json

RUN chmod +x /entrypoint.sh /usr/local/bin/consul-template

WORKDIR /working

ENTRYPOINT [ "/entrypoint.sh" ]`

