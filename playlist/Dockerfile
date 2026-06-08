# syntax=docker/dockerfile:1

FROM ubuntu:24.04 AS build

ARG XI_VERSION=latest
ARG TARGETARCH

WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates clang curl tar \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    docker_arch="${TARGETARCH:-$(uname -m)}"; \
    case "$docker_arch" in \
        amd64|x86_64) xi_arch="x86_64" ;; \
        arm64|aarch64) xi_arch="arm64" ;; \
        *) echo "unsupported target architecture: ${docker_arch}" >&2; exit 1 ;; \
    esac; \
    if [ "$XI_VERSION" = "latest" ]; then \
        xi_version="$(curl -fsSL https://api.github.com/repos/code-by-sia/x/releases/latest \
            | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"; \
    else \
        xi_version="$XI_VERSION"; \
    fi; \
    xi_asset="xi-${xi_version}-linux-${xi_arch}.tar.gz"; \
    curl -fsSL "https://github.com/code-by-sia/x/releases/download/${xi_version}/${xi_asset}" -o "/tmp/${xi_asset}"; \
    mkdir -p /opt/xi; \
    tar -xzf "/tmp/${xi_asset}" -C /opt/xi --strip-components=1

ENV PATH="/opt/xi/bin:${PATH}" \
    XC_HOME="/opt/xi" \
    XC_STD="/opt/xi" \
    XC_RUNTIME="/opt/xi/runtime"

COPY common ./common
COPY playlist ./playlist
RUN xc playlist/playlist-service.xi

FROM ubuntu:24.04 AS runtime

WORKDIR /app

COPY --from=build /workspace/build/playlist-service /app/playlist-service

EXPOSE 5001
VOLUME ["/app/data"]

CMD ["/app/playlist-service"]
