FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    clang \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/odin-lang/Odin/releases/download/dev-2026-06/odin-linux-amd64-dev-2026-06.tar.gz -o odin.tar.gz \
    && tar -xf odin.tar.gz -C /opt \
    && mv /opt/odin-linux-amd64-* /opt/odin \
    && rm odin.tar.gz

ENV ODIN_ROOT=/opt/odin

ENV PATH="${ODIN_ROOT}:${PATH}"
