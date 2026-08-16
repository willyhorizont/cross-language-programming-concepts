FROM debian:trixie AS extractor

ARG FNX_ODIN=odin-linux-amd64-dev-2026-06.tar.gz

COPY tmp/${FNX_ODIN} /tmp/

RUN mkdir -p /opt \
    && tar -xf /tmp/${FNX_ODIN} -C /opt \
    && mv /opt/odin-linux-amd64-* /opt/odin

FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    clang \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /opt/odin /opt/odin

ENV ODIN_ROOT=/opt/odin

ENV PATH="${ODIN_ROOT}:${PATH}"
