FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/pharo

RUN curl \
    --connect-timeout 60 \
    --retry 5 \
    --retry-delay 10 \
    --max-time 1800 \
    -sSfL "https://get.pharo.org/130+vm" | bash \
    && ln -s /opt/pharo/pharo /usr/local/bin/pharo
