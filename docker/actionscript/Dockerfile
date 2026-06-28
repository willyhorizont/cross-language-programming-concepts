FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L "https://archive.apache.org/dist/flex/4.16.1/binaries/apache-flex-sdk-4.16.1-bin.tar.gz" -o /apache-flex-sdk-4.16.1-bin.tar.gz

RUN mkdir /apache-flex-sdk && \
    tar -xzf /apache-flex-sdk-4.16.1-bin.tar.gz -C /apache-flex-sdk --strip-components=1 && \
    rm /apache-flex-sdk-4.16.1-bin.tar.gz

RUN mkdir -p /playerglobal/27.0 && \
    curl -L "https://github.com/nexussays/playerglobal/raw/refs/heads/master/27.0/playerglobal.swc" -o /playerglobal/27.0/playerglobal.swc

RUN sed -i 's|{playerglobalHome}|/playerglobal|g' /apache-flex-sdk/frameworks/flex-config.xml

RUN chmod +x /apache-flex-sdk/bin/mxmlc

ENV FLEX_HOME=/apache-flex-sdk
ENV PATH="${PATH}:${FLEX_HOME}/bin"
