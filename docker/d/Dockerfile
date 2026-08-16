FROM debian:trixie AS extractor

RUN apt-get update && apt-get install -y --no-install-recommends \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

ARG FNX_DMD=dmd.2.112.0.linux.tar.xz

COPY tmp/${FNX_DMD} /tmp/

RUN mkdir -p /usr/local && tar -xf /tmp/${FNX_DMD} -C /usr/local

FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /usr/local/dmd2 /usr/local/dmd2

ENV PATH=/usr/local/dmd2/linux/bin64:${PATH}
