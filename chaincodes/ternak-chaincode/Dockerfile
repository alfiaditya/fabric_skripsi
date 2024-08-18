# SPDX-License-Identifier: Apache-2.0
#
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Copy node.js source and build, changing owner as well
COPY --chown=node:node . /usr/src/app
ENV npm_config_cache=/usr/src/app
RUN npm install
RUN npm run build && npm shrinkwrap


FROM node:18-alpine as prod-builder
WORKDIR /usr/src/app
COPY --chown=node:node --from=builder /usr/src/app/dist ./dist
COPY --chown=node:node --from=builder /usr/src/app/package.json ./
COPY --chown=node:node --from=builder /usr/src/app/npm-shrinkwrap.json ./
RUN npm ci --omit=dev && npm cache clean --force

# ------------------------------------------------------------------------------
# Builds the Chaincode as a Service docker version
FROM node:18-alpine AS ccaas
WORKDIR /usr/src/app

COPY --chown=node:node --from=prod-builder /usr/src/app .
COPY --chown=node:node docker/docker-entrypoint.sh /usr/src/app/docker-entrypoint.sh

ARG CC_SERVER_PORT
ENV PORT $CC_SERVER_PORT
EXPOSE $CC_SERVER_PORT
ENV NODE_ENV=production
USER node
ENTRYPOINT [ "/tini", "--", "/usr/src/app/docker-entrypoint.sh" ]