ARG BUILD_FROM=ghcr.io/hassio-addons/ubuntu-base:8.1.2
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy Python requirements file
COPY requirements.txt /tmp/

# Setup base
# hadolint ignore=DL3042 
RUN apt-get update && \
    apt-get install -y software-properties-common python3 python3-pip gcc \
    git libatlas3-base libavformat58 portaudio19-dev pulseaudio python3-pip avahi-daemon nginx && \
    apt-get clean && \
    pip install --upgrade pip wheel setuptools && \
    pip install -r /tmp/requirements.txt


RUN pip install --force-reinstall --ignore-installed git+https://github.com/LedFx/LedFx

RUN \
    rm -fr \
    /etc/nginx \
    /root/.cache \
    /tmp/*

# Copy root filesystem
COPY rootfs /

RUN chown -R root /etc/cont-init.d
RUN chown -R root /etc/services.d
RUN chmod -R +x /etc/cont-init.d/*
RUN chmod -R +x /etc/services.d/*

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME 
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Sebastian Chmiel <sebastian@chmiel.io>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Sebastian Chmiel <sebastian@chmiel.io>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
