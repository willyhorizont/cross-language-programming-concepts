FROM debian:trixie

# https://docs.cangjie-lang.cn/en/docs/1.0.0/user_manual/source_en/Appendix/linux_toolchain_install.html
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    binutils \
    gcc \
    g++ \
    libc-dev \
    libc++-dev \
    libgcc-s1 \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/cangjie.tar.gz "https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.3.tar.gz&objectKey=6a19349d21f5a8178d6fd22b" \
    && tar -xzf /tmp/cangjie.tar.gz -C /usr/local \
    && rm /tmp/cangjie.tar.gz

ENV CANGJIE_HOME=/usr/local/cangjie
ENV PATH=$CANGJIE_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$CANGJIE_HOME/lib:$CANGJIE_HOME/runtime/lib/linux_x86_64_cjnative
