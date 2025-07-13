FROM alpine:3.22

RUN apk add --no-cache \
    wireguard-tools \
    iproute2 \
    iptables \
    curl \
    wget \
    ca-certificates \
    bash \
    grep \
    sed \
    coreutils

# Install wgcf
ARG TARGETARCH
RUN WGCF_VERSION=$(wget -qO- https://api.github.com/repos/ViRb3/wgcf/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    wget -q "https://github.com/ViRb3/wgcf/releases/download/${WGCF_VERSION}/wgcf_${WGCF_VERSION#v}_linux_${TARGETARCH}" -O /usr/local/bin/wgcf && \
    chmod +x /usr/local/bin/wgcf

WORKDIR /app

# Build argument for version
ARG VERSION=dev
ENV VERSION=${VERSION}

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

VOLUME ["/etc/wireguard"]

# Health check every 30s, timeout 10s, start after 30s, retry 3 times
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wg show warp >/dev/null 2>&1 || exit 1

ENTRYPOINT ["/app/entrypoint.sh"]