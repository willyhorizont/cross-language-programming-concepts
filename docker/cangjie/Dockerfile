FROM debian:trixie AS extractor

ARG FNX_CANGJIE=cangjie-sdk-linux-x64-1.1.3.tar.gz

COPY tmp/${FNX_CANGJIE} /tmp/

RUN mkdir -p /usr/local && tar -xzf /tmp/${FNX_CANGJIE} -C /usr/local

FROM debian:trixie

# https://docs.cangjie-lang.cn/en/docs/1.0.0/user_manual/source_en/Appendix/linux_toolchain_install.html
RUN apt-get update && apt-get install -y --no-install-recommends \
    binutils \
    gcc \
    g++ \
    libc-dev \
    libc++-dev \
    libgcc-s1 \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /usr/local/cangjie /usr/local/cangjie

ENV CANGJIE_HOME=/usr/local/cangjie
ENV PATH=$CANGJIE_HOME/bin:${PATH}
ENV LD_LIBRARY_PATH=$CANGJIE_HOME/lib:$CANGJIE_HOME/runtime/lib/linux_x86_64_cjnative
