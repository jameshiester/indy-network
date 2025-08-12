FROM ubuntu:22.04

LABEL org.opencontainers.image.title="indy-vdr-proxy"
LABEL org.opencontainers.image.description="Container for Hyperledger Indy VDR proxy"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       tar \
       libc6 \
    && rm -rf /var/lib/apt/lists/*

# Download and extract indy-vdr (library + proxy) release
ENV VDR_RELEASE_URL="https://github.com/hyperledger/indy-vdr/releases/download/v0.4.3"
ENV VDR_TARBALL="library-linux-x86_64.tar.gz"
ENV VDR_PROXY_TARBALL="proxy-linux-x86_64.tar.gz"

RUN mkdir -p /opt/indy-vdr
RUN curl -sSL "$VDR_RELEASE_URL/$VDR_TARBALL" -o /tmp/indy-vdr.tar.gz
RUN tar -xzf /tmp/indy-vdr.tar.gz -C /opt/indy-vdr
RUN rm -f /tmp/indy-vdr.tar.gz
RUN cp /opt/indy-vdr/libindy_vdr.so /usr/local/lib/


# Defaults; can be overridden at runtime
ENV VDR_PROXY_PORT=8080
ENV VDR_GENESIS_PATH=

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

