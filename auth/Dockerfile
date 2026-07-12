# syntax=docker/dockerfile:1

FROM homebrew/brew:latest AS build

USER root
WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates clang libsqlite3-dev \
    && chown -R linuxbrew:linuxbrew /workspace \
    && rm -rf /var/lib/apt/lists/*

USER linuxbrew
ENV PATH="/home/linuxbrew/xi/bin:${PATH}"

# Install the Xi toolchain straight from the GitHub release. The Homebrew
# formula lags behind, so pin (and bump) the version here instead.
ARG XI_VERSION=0.0.98
RUN arch="$(uname -m)" \
    && case "$arch" in \
         aarch64|arm64) asset="linux-arm64" ;; \
         x86_64|amd64)  asset="linux-x86_64" ;; \
         *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
       esac \
    && mkdir -p /home/linuxbrew/xi \
    && curl -fsSL "https://github.com/code-by-sia/xi/releases/download/v${XI_VERSION}/xi-v${XI_VERSION}-${asset}.tar.gz" \
       | tar xz -C /home/linuxbrew/xi --strip-components=1

COPY --chown=linuxbrew:linuxbrew common ./common
COPY --chown=linuxbrew:linuxbrew auth ./auth
COPY --chown=linuxbrew:linuxbrew auth-service.xi ./
# Fetch the xi-sqlite dependency into ./modules, then build.
RUN xi install auth-service.xi && xc auth-service.xi

FROM ubuntu:24.04 AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /workspace/build/auth-service /app/auth-service
COPY --from=build /workspace/common/config.yaml /app/common/config.yaml

EXPOSE 4001
VOLUME ["/app/data"]

CMD ["/app/auth-service"]
