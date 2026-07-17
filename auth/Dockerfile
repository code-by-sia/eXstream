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
COPY --chown=linuxbrew:linuxbrew auth ./auth
COPY --chown=linuxbrew:linuxbrew auth-service.xi ./
RUN xc auth-service.xi

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
