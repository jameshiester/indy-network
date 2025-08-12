FROM node:22-alpine

RUN apk add --no-cache git cmake build-base curl

# Python for node-gyp (and bash since CMD uses /bin/bash)
RUN apk add --no-cache python3 py3-pip python3-dev bash
RUN ln -sf /usr/bin/python3 /usr/bin/python
ENV npm_config_python=/usr/bin/python3

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
RUN chmod -R 0777 /app

EXPOSE 8080

CMD ["/app/packages/server/build/main.js"]