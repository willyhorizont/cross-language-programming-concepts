FROM debian:trixie AS extractor

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    && rm -rf /var/lib/apt/lists/*

ARG FNX_WREN=wren-cli-linux-0.4.0.zip

COPY tmp/${FNX_WREN} /tmp/

RUN unzip /tmp/${FNX_WREN} -d /tmp \
    && mkdir -p /opt/wren/bin \
    && mv /tmp/wren-cli-linux-0.4.0/wren_cli /opt/wren/bin/wren

FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    libuv1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /opt/wren/bin/wren /usr/local/bin/wren
