FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://ziglang.org/download/0.16.0/zig-x86_64-linux-0.16.0.tar.xz -o zig.tar.xz \
    && tar -xf zig.tar.xz -C /opt \
    && ln -s /opt/zig-x86_64-linux-0.16.0/zig /usr/local/bin/zig \
    && rm zig.tar.xz
