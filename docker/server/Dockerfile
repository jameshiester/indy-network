FROM node:22-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl git cmake bash make gcc g++ \
        python3 python3-pip build-essential \
        libsodium23 libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/indy-vdr

RUN curl -L -o /tmp/indy-vdr/library-linux-x86_64.tar.gz https://github.com/hyperledger/indy-vdr/releases/download/v0.4.3/library-linux-x86_64.tar.gz \
    && tar -xz -C /tmp/indy-vdr -f /tmp/indy-vdr/library-linux-x86_64.tar.gz \
    && mv /tmp/indy-vdr/libindy_vdr.so /usr/local/lib/libindy_vdr.so \
    && rm -rf /tmp/indy-vdr

ENV LD_LIBRARY_PATH=/usr/local/lib

WORKDIR /app

RUN npm install -g pnpm node-gyp turbo@2.0.6
COPY ./packages/server /app/packages/server
COPY ./packages/client/package.json /app/packages/client/package.json
COPY ./package.json /app/package.json
COPY ./turbo.json /app/turbo.json
COPY ./pnpm-lock.yaml /app/pnpm-lock.yaml
COPY ./pnpm-workspace.yaml /app/pnpm-workspace.yaml

RUN pnpm install
RUN turbo run build --filter=api

EXPOSE 8080

CMD ["node","/app/packages/server/build/main.js"]