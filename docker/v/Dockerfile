FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/v_linux.zip "https://github.com/vlang/v/releases/download/0.5.2/v_linux.zip" \
    && unzip /tmp/v_linux.zip -d /tmp \
    && mkdir -p /opt/v \
    && mv /tmp/v/* /opt/v \
    && rm /tmp/v_linux.zip \
    && rm -rf /tmp/v

ENV PATH="/opt/v:${PATH}"
