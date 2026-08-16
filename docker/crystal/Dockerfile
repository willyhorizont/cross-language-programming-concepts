FROM debian:trixie AS extractor

ARG FNX_CRYSTAL=crystal-1.21.0-1-linux-x86_64-bundled.tar.gz

COPY tmp/${FNX_CRYSTAL} /tmp/

RUN mkdir -p /usr/local && tar -xzf /tmp/${FNX_CRYSTAL} -C /usr/local

FROM debian:trixie

# https://github.com/crystal-lang/crystal/wiki/All-required-libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /usr/local/crystal-1.21.0-1 /usr/local/crystal-1.21.0-1
RUN ln -s /usr/local/crystal-1.21.0-1 /usr/local/crystal

ENV PATH=/usr/local/crystal/bin:${PATH}
