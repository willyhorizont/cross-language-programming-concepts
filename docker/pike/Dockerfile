FROM debian:trixie AS extractor

# https://github.com/pikelang/Pike/blob/v8.0.1956/README-GIT
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    m4 \
    bison \
    libc6-dev \
    libgmp-dev \
    nettle-dev \
    libpcre2-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CFLAGS="-Wno-implicit-function-declaration"
ENV CXXFLAGS="-Wno-implicit-function-declaration"

ARG FNX_PIKE=Pike-v8.0.1956.tar.gz

COPY tmp/${FNX_PIKE} /tmp/

RUN mkdir -p /tmp/pike \
    && tar -xzf /tmp/${FNX_PIKE} -C /tmp/pike --strip-components=1 \
    && cd /tmp/pike/src \
    && ./configure --prefix=/opt/pike \
    && make \
    && make install

FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    libc6 \
    libgmp10 \
    libnettle8 \
    libpcre2-8-0 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /opt/pike /opt/pike

ENV PATH="/opt/pike/bin:${PATH}"
