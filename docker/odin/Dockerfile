FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    clang \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/odin.tar.gz https://github.com/odin-lang/Odin/releases/download/dev-2026-06/odin-linux-amd64-dev-2026-06.tar.gz \
    && tar -xf /tmp/odin.tar.gz -C /opt \
    && mv /opt/odin-linux-amd64-* /opt/odin \
    && rm /tmp/odin.tar.gz

ENV ODIN_ROOT=/opt/odin

ENV PATH="${ODIN_ROOT}:${PATH}"
