FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    xz-utils \
    gcc \
    libc6-dev \
    libglib2.0-dev \
    gobject-introspection \
    libgirepository1.0-dev \
    flex \
    bison \
    libgraphviz-dev \
    pkg-config \
    make \
    autoconf \
    autoconf-archive \
    automake \
    libtool \
    libgee-0.8-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/vala.tar.xz "https://download.gnome.org/sources/vala/0.56/vala-0.56.19.tar.xz" \
    && tar -xf /tmp/vala.tar.xz -C /tmp \
    && cd /tmp/vala-0.56.19 \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    && ldconfig \
    && rm /tmp/vala.tar.xz \
    && rm -rf /tmp/vala-0.56.19
