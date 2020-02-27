FROM alpine:latest

# Define Environment variables
ENV PROMETHEUS_VERSION=${VERSION} \
    PERMISSON_PATHS="/opt/prometheus" \
    STORAGE_SIZE=${STORAGE_SIZE}

# install alpine packages
RUN apk update; \
    apk upgrade --update; \
    apk add --update --no-cache \
        curl; \
    apk cache clean; \
    rm -rf /var/cache/apk/*; \
    rm -rf /tmp/*;

RUN set -xe; \
    # create needed paths
    mkdir -p ${PERMISSON_PATHS}; \
    # download prometheus
    curl -L https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
         -o /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz; \
    # unpack and move prometheus
    tar -xzf /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz -C /tmp; \
    ls -la /tmp; \
    mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/* /opt/prometheus/; \
    rm -rf /tmp/*; \
    ls -la /tmp;

# set path permissions
RUN set -xe \
    chgrp -R nobody ${PERMISSON_PATHS}; \
    chmod -R 777 ${PERMISSON_PATHS}; \
    ls -la ${PERMISSON_PATHS};

ENTRYPOINT /opt/prometheus/prometheus \
           --config.file=/etc/prometheus/prometheus.yml \
           --storage.tsdb.path=/data \
           --storage.tsdb.retention.size=${STORAGE_SIZE}GB \
           --web.enable-lifecycle