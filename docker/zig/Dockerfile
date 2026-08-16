FROM debian:trixie AS extractor

RUN apt-get update && apt-get install -y --no-install-recommends \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

ARG FNX_ZIG=zig-x86_64-linux-0.16.0.tar.xz

COPY tmp/${FNX_ZIG} /tmp/

RUN mkdir -p /opt && tar -xf /tmp/${FNX_ZIG} -C /opt

FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /opt/zig-x86_64-linux-0.16.0 /opt/zig-x86_64-linux-0.16.0

RUN ln -s /opt/zig-x86_64-linux-0.16.0/zig /usr/local/bin/zig
