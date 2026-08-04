FROM debian:trixie

# https://github.com/crystal-lang/crystal/wiki/All-required-libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gcc \
    libc6-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/crystal.tar.gz "https://github.com/crystal-lang/crystal/releases/download/1.21.0/crystal-1.21.0-1-linux-x86_64-bundled.tar.gz" \
    && tar -xzf /tmp/crystal.tar.gz -C /usr/local \
    && ln -s /usr/local/crystal-1.21.0-1 /usr/local/crystal \
    && rm /tmp/crystal.tar.gz

ENV PATH=/usr/local/crystal/bin:${PATH}
