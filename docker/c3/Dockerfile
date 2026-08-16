FROM debian:trixie AS extractor

ARG FNX_C3=c3-v0.8.2-linux-static.tar.gz

COPY tmp/${FNX_C3} /tmp/

RUN mkdir -p /usr/local && tar -xzf /tmp/${FNX_C3} -C /usr/local

FROM debian:trixie

# https://c3-lang.org/getting-started/prebuilt-binaries/
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /usr/local/c3 /usr/local/c3

ENV PATH=/usr/local/c3:${PATH}
