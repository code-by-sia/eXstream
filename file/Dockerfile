# syntax=docker/dockerfile:1

FROM homebrew/brew:latest AS build

USER root
WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates clang openssh-client \
    && chown -R linuxbrew:linuxbrew /workspace \
    && rm -rf /var/lib/apt/lists/*

USER linuxbrew
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}" \
    HOMEBREW_NO_ANALYTICS=1 \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_ENV_HINTS=1

RUN --mount=type=ssh \
    mkdir -p /home/linuxbrew/.ssh \
    && ssh-keyscan github.com >> /home/linuxbrew/.ssh/known_hosts \
    && git config --global url."git@github.com:".insteadOf "https://github.com/" \
    && brew install code-by-sia/x/xi \
    && git config --global --unset-all url."git@github.com:".insteadOf

COPY --chown=linuxbrew:linuxbrew common ./common
COPY --chown=linuxbrew:linuxbrew file ./file
RUN xc file/file-service.xi

FROM ubuntu:24.04 AS runtime

WORKDIR /app

COPY --from=build /workspace/build/file-service /app/file-service

EXPOSE 6001
VOLUME ["/app/data"]

CMD ["/app/file-service"]
