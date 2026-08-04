# https://github.com/pascalecu/clang-objc2-gnustep/blob/main/Dockerfile
# syntax=docker/dockerfile:1
FROM debian:trixie AS builder

ARG CLANG_VERSION=19

ARG TOOLS_MAKE_REF=50cf9619e672fb2ff6825f239b5a172c5dc55630
ARG LIBOBJC2_REF=fe3b225029f50fc3140bfa9d7d98690d1c6f490c
ARG LIBDISPATCH_REF=swift-6.3.1-RELEASE
ARG LIBS_BASE_REF=f3547bec33c8bc4ad6dc8389ffb96279d3d5a295

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    CC=clang-${CLANG_VERSION} \
    CXX=clang++-${CLANG_VERSION} \
    GNUSTEP_PREFIX=/opt/gnustep \
    PATH="/opt/gnustep/bin:/opt/gnustep/sbin:${PATH}" \
    MAKEFLAGS="-j$(nproc)"

WORKDIR /build

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt install -y --no-install-recommends \
    git clang-${CLANG_VERSION} build-essential cmake ninja-build wget \
    autoconf libtool pkg-config ca-certificates \
    libffi-dev libxml2-dev libxslt1-dev \
    libgnutls28-dev libicu-dev libblocksruntime-dev zlib1g-dev

# =========================
# tools-make
# =========================
RUN git clone https://github.com/gnustep/tools-make.git && \
    cd tools-make && \
    git checkout ${TOOLS_MAKE_REF} && \
    ./configure \
    --prefix=${GNUSTEP_PREFIX} \
    --with-layout=fhs \
    --disable-importing-config-file \
    --enable-native-objc-exceptions \
    --enable-objc-arc \
    --with-library-combo=ng-gnu-gnu && \
    make install

# =========================
# libobjc2
# =========================
RUN git clone https://github.com/gnustep/libobjc2.git && \
    cd libobjc2 && \
    git checkout ${LIBOBJC2_REF} && \
    cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${GNUSTEP_PREFIX} \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DTESTS=OFF && \
    ninja -C build install

# =========================
# libdispatch
# =========================
RUN git clone --depth 1 --branch ${LIBDISPATCH_REF} https://github.com/apple/swift-corelibs-libdispatch.git && \
    cd swift-corelibs-libdispatch && \
    cmake -S . -B build -G Ninja \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${GNUSTEP_PREFIX} \
    -DWITH_BLOCKS_RUNTIME=YES \
    -DCMAKE_C_FLAGS="-Wno-error=sign-conversion" && \
    ninja -C build install

# =========================
# libs-base
# =========================
RUN git clone https://github.com/gnustep/libs-base.git && \
    cd libs-base && \
    git checkout ${LIBS_BASE_REF} && \
    set +u && \
    . ${GNUSTEP_PREFIX}/share/GNUstep/Makefiles/GNUstep.sh && \
    set -u && \
    ./configure \
    --prefix=${GNUSTEP_PREFIX} \
    --enable-release \
    --with-library-combo=ng-gnu-gnu \
    --disable-importing-config-file && \
    make install

# =========================
# cleanup and strip
# =========================
RUN find ${GNUSTEP_PREFIX}/lib -type f -name "*.a" -delete && \
    find ${GNUSTEP_PREFIX} -type f \( -executable -o -name "*.so*" \) \
    -exec strip --strip-unneeded {} + 2>/dev/null || true

# =========================
# runtime
# =========================
FROM debian:trixie AS runtime
ARG CLANG_VERSION=19
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt install -y --no-install-recommends \
        clang-${CLANG_VERSION} \
        libffi8 \
        libxml2 \
        libxslt1.1 \
        libgnutls30 \
        libicu76 \
        libblocksruntime0 \
        zlib1g \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/gnustep /opt/gnustep

ENV PATH="/opt/gnustep/bin:/opt/gnustep/sbin:${PATH}" \
    GNUSTEP_MAKEFILES="/opt/gnustep/share/GNUstep/Makefiles"

RUN echo "/opt/gnustep/lib" > /etc/ld.so.conf.d/gnustep.conf && ldconfig

COPY <<EOF /usr/local/bin/objc
#!/usr/bin/env bash
set -euo pipefail

export GNUSTEP_MAKEFILES=/opt/gnustep/share/GNUstep/Makefiles
set +u
source /opt/gnustep/share/GNUstep/Makefiles/GNUstep.sh
set -u

exec clang-${CLANG_VERSION} \\
    -fobjc-runtime=gnustep-2.0 \\
    -fobjc-arc \\
    -fblocks \\
    -fobjc-exceptions \\
    -O2 \\
    -I/opt/gnustep/include \\
    -L/opt/gnustep/lib \\
    -Wl,-rpath,/opt/gnustep/lib \\
    "\$@" \\
    -lgnustep-base -lobjc -ldispatch -lpthread -ldl -lm
EOF

RUN chmod +x /usr/local/bin/objc

WORKDIR /workdir
CMD ["/bin/bash"]
