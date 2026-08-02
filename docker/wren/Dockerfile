FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    libuv1 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/wren.zip https://github.com/wren-lang/wren-cli/releases/download/0.4.0/wren-cli-linux-0.4.0.zip \
    && unzip /tmp/wren.zip -d /tmp \
    && mv /tmp/wren-cli-linux-0.4.0/wren_cli /usr/local/bin/wren \
    && rm -rf /tmp/*
