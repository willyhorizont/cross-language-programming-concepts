FROM debian:trixie AS extractor

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ARG FNX_V=v-0.5.2-linux.zip

COPY tmp/${FNX_V} /tmp/

RUN unzip /tmp/${FNX_V} -d /tmp \
    && mkdir -p /opt/v \
    && mv /tmp/v/* /opt/v

FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /opt/v /opt/v

ENV PATH="/opt/v:${PATH}"
