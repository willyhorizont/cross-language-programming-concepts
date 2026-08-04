FROM debian:trixie

# https://c3-lang.org/getting-started/prebuilt-binaries/
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gcc \
    libc-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/c3.tar.gz "https://github.com/c3lang/c3c/releases/download/v0.8.2/c3-linux-static.tar.gz" \
    && tar -xzf /tmp/c3.tar.gz -C /usr/local \
    && rm /tmp/c3.tar.gz

ENV PATH=/usr/local/c3:${PATH}
