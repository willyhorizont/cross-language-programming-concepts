FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    xz-utils \
    build-essential \
    binutils \
    scdoc \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://c9x.me/compile/release/qbe-1.3.tar.xz \
    && tar -xf qbe-1.3.tar.xz \
    && cd qbe-1.3 \
    && make \
    && make install \
    && cd .. && rm -rf qbe-1.3*

RUN curl -O https://git.sr.ht/~sircmpwn/harec/archive/0.26.0.tar.gz \
    && tar -xf 0.26.0.tar.gz \
    && cd harec-0.26.0 \
    && cp configs/linux.mk config.mk \
    && make \
    && make install \
    && cd .. && rm -rf harec-0.26.0 0.26.0.tar.gz

RUN curl -O https://git.sr.ht/~sircmpwn/hare/archive/0.26.0.tar.gz \
    && tar -xf 0.26.0.tar.gz \
    && cd hare-0.26.0 \
    && cp configs/linux.mk config.mk \
    && make hare \
    && make install \
    && cd .. && rm -rf hare-0.26.0 0.26.0.tar.gz
