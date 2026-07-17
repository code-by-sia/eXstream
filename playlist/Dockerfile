# syntax=docker/dockerfile:1

FROM homebrew/brew:latest AS build

USER root
WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates clang libsqlite3-dev \
    && chown -R linuxbrew:linuxbrew /workspace \
    && rm -rf /var/lib/apt/lists/*

USER linuxbrew
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}" \
    HOMEBREW_NO_ANALYTICS=1 \
    HOMEBREW_NO_ENV_HINTS=1

# Install the Xi toolchain from the Homebrew tap (tracks the latest release).
RUN brew install code-by-sia/xi/xi

COPY --chown=linuxbrew:linuxbrew common ./common
COPY --chown=linuxbrew:linuxbrew playlist ./playlist
COPY --chown=linuxbrew:linuxbrew playlist-service.xi ./
RUN xc playlist-service.xi

FROM ubuntu:24.04 AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /workspace/build/playlist-service /app/playlist-service
COPY --from=build /workspace/common/config.yaml /app/common/config.yaml

EXPOSE 5001
VOLUME ["/app/data"]

CMD ["/app/playlist-service"]
