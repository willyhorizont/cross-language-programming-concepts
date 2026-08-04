FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    xz-utils \
    gcc \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/dmd.tar.xz "https://downloads.dlang.org/releases/2.x/2.112.0/dmd.2.112.0.linux.tar.xz" \
    && tar -xf /tmp/dmd.tar.xz -C /usr/local \
    && rm /tmp/dmd.tar.xz

ENV PATH=/usr/local/dmd2/linux/bin64:${PATH}
