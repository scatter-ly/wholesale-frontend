# yarn install
# yarn build:dev

FROM node:20-bookworm-slim
LABEL org.opencontainers.image.source=https://github.com/scatter-ly/wholesale-frontend

# Configure apt caching for use with BuildKit.
# The default Debian Docker image has special apt config to clear caches,
# but if we are using --mount=type=cache, then we want to keep the files.
# https://github.com/debuerreotype/debuerreotype/blob/master/scripts/debuerreotype-minimizing-config
RUN set -exu && \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache && \
    echo 'Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/99use-gzip-compression

RUN --mount=type=cache,id=apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=apt-lib,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,id=debconf,target=/var/cache/debconf,sharing=locked \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install -y -qq --no-install-recommends \
      ca-certificates curl jq netcat-openbsd yq && \
      rm -rf /usr/share/postgresql/*/man

WORKDIR /app
RUN chown node:node /app
USER node

# This switches many Node.js dependencies to production mode.
ENV NODE_ENV=production

# Copy repo skeleton first, to avoid unnecessary docker cache invalidation.
# The skeleton contains the package.json of each package in the monorepo,
# and along with yarn.lock and the root package.json, that's enough to run yarn install.
COPY --chown=node:node .yarn ./.yarn
COPY --chown=node:node .yarnrc.yml ./
COPY --chown=node:node yarn.lock package.json ./
COPY --chown=node:node dist ./dist

RUN --mount=type=cache,target=/home/node/.yarn/berry/cache,sharing=locked,uid=1000,gid=1000 \
    yarn install --immutable

# Then copy the rest of the backend bundle, along with any other files we might want.
CMD ["node", "dist/index.js"]
