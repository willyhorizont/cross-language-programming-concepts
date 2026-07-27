FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/jdk-7u80-linux-x64.tar.gz "https://repo.huaweicloud.com/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz"

RUN mkdir -p /usr/lib/jvm && \
    tar -zxvf /tmp/jdk-7u80-linux-x64.tar.gz -C /usr/lib/jvm/ && \
    rm /tmp/jdk-7u80-linux-x64.tar.gz

# RUN curl -L -o /tmp/apache-flex-sdk-4.16.1-bin.tar.gz "https://archive.apache.org/dist/flex/4.16.1/binaries/apache-flex-sdk-4.16.1-bin.tar.gz"
RUN curl -L -o /tmp/apache-flex-sdk-4.16.1-bin.tar.gz "https://dlcdn.apache.org/flex/4.16.1/binaries/apache-flex-sdk-4.16.1-bin.tar.gz"

RUN mkdir /apache-flex-sdk && \
    tar -xzf /tmp/apache-flex-sdk-4.16.1-bin.tar.gz -C /apache-flex-sdk --strip-components=1 && \
    rm /tmp/apache-flex-sdk-4.16.1-bin.tar.gz

RUN mkdir -p /playerglobal/27.0

RUN curl -L -o /playerglobal/27.0/playerglobal.swc "https://github.com/nexussays/playerglobal/raw/refs/heads/master/27.0/playerglobal.swc"

RUN sed -i 's|{playerglobalHome}|/playerglobal|g' /apache-flex-sdk/frameworks/flex-config.xml

RUN chmod +x /apache-flex-sdk/bin/mxmlc

ENV JAVA_HOME=/usr/lib/jvm/jdk1.7.0_80
ENV FLEX_HOME=/apache-flex-sdk
ENV PATH="${PATH}:${JAVA_HOME}/bin:${FLEX_HOME}/bin"
