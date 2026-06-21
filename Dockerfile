ARG OS_VERSION=22.04

FROM ubuntu:${OS_VERSION} AS base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    ca-certificates \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 \
    && chmod +x /usr/local/bin/confd

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN sudo tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN sudo tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

VOLUME ["/certs", "/config"]
EXPOSE 53/udp 80 443

COPY rootfs/ /

RUN chmod o+x {} /etc/services.d/*/run /etc/cont-init.d/*

ENTRYPOINT ["/init"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl -fsSL "http://127.0.0.1:${SVC_PORT:-8888}/health" || exit 1