FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    make \
    gcc \
    libc6-dev \
    libuv1-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN git clone --branch 0.4.0 --depth 1 --recursive https://github.com/wren-lang/wren-cli.git .

RUN sed -i 's/\bwrite\b/wrenWrite/g' src/cli/vm.c

WORKDIR /build/projects/make

RUN make config=release_64bit

RUN cp /build/bin/wren_cli /usr/local/bin/wren

WORKDIR /

RUN rm -rf /build
