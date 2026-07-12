# syntax=docker/dockerfile:1

FROM homebrew/brew:latest AS build

USER root
WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates clang \
    && chown -R linuxbrew:linuxbrew /workspace \
    && rm -rf /var/lib/apt/lists/*

USER linuxbrew
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}" \
    HOMEBREW_NO_ANALYTICS=1 \
    HOMEBREW_NO_ENV_HINTS=1

# Install the Xi toolchain from the Homebrew tap (tracks the latest release).
RUN brew install code-by-sia/xi/xi

COPY --chown=linuxbrew:linuxbrew common ./common
COPY --chown=linuxbrew:linuxbrew file ./file
COPY --chown=linuxbrew:linuxbrew file-service.xi ./
RUN xc file-service.xi

FROM ubuntu:24.04 AS runtime

WORKDIR /app

COPY --from=build /workspace/build/file-service /app/file-service
COPY --from=build /workspace/common/config.yaml /app/common/config.yaml

EXPOSE 6001
VOLUME ["/app/data"]

CMD ["/app/file-service"]
