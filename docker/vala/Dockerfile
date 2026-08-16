FROM debian:trixie AS extractor

# https://gitlab.gnome.org/GNOME/vala/-/tree/0.56.19
RUN apt-get update && apt-get install -y --no-install-recommends \
    xz-utils \
    gcc \
    libc6-dev \
    libglib2.0-dev \
    flex \
    bison \
    libgraphviz-dev \
    pkg-config \
    make \
    autoconf \
    autoconf-archive \
    automake \
    libtool \
    gobject-introspection \
    libgirepository1.0-dev \
    && rm -rf /var/lib/apt/lists/*

ARG FNX_VALA=vala-0.56.19.tar.xz

COPY tmp/${FNX_VALA} /tmp/

RUN mkdir -p /tmp/vala-src \
    && tar -xf /tmp/${FNX_VALA} -C /tmp/vala-src --strip-components=1 \
    && cd /tmp/vala-src \
    && ./configure --prefix=/opt/vala \
    && make \
    && make install

FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    libglib2.0-dev \
    libgraphviz-dev \
    libgirepository1.0-dev \
    gobject-introspection \
    libgee-0.8-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /opt/vala /opt/vala

RUN echo "/opt/vala/lib" > /etc/ld.so.conf.d/vala.conf && ldconfig

ENV PATH="/opt/vala/bin:${PATH}"
