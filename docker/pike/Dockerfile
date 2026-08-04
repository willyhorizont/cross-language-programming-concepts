FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gcc \
    g++ \
    make \
    libc6-dev \
    libgmp-dev \
    nettle-dev \
    libpcre2-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CFLAGS="-Wno-implicit-function-declaration"
ENV CXXFLAGS="-Wno-implicit-function-declaration"

RUN curl -L -o /tmp/pike.tar.gz "https://pike.lysator.liu.se/pub/pike/latest-stable/Pike-v8.0.1956.tar.gz" \
    && mkdir -p /tmp/pike \
    && tar -xzf /tmp/pike.tar.gz -C /tmp/pike --strip-components=1 \
    && cd /tmp/pike/src \
    && ./configure \
    && make \
    && make install \
    && rm /tmp/pike.tar.gz \
    && rm -rf /tmp/pike
