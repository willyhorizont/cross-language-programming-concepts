FROM debian:bookworm AS extractor

ARG FNX_JDK=jdk-7u80-linux-x64.tar.gz
ARG FNX_FLEX=apache-flex-sdk-4.16.1-bin.tar.gz
ARG FNX_SWC=playerglobal27.0.swc

COPY tmp/${FNX_JDK} /tmp/
COPY tmp/${FNX_FLEX} /tmp/
COPY tmp/${FNX_SWC} /tmp/

RUN mkdir -p /usr/lib/jvm && tar -zxvf /tmp/${FNX_JDK} -C /usr/lib/jvm/
RUN mkdir -p /apache-flex-sdk && tar -xzf /tmp/${FNX_FLEX} -C /apache-flex-sdk --strip-components=1
RUN mkdir -p /playerglobal/27.0 && cp /tmp/${FNX_SWC} /playerglobal/27.0/playerglobal.swc

FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /usr/lib/jvm/ /usr/lib/jvm/
COPY --from=extractor /apache-flex-sdk/ /apache-flex-sdk/
COPY --from=extractor /playerglobal/ /playerglobal/

RUN sed -i 's|{playerglobalHome}|/playerglobal|g' /apache-flex-sdk/frameworks/flex-config.xml

RUN chmod +x /apache-flex-sdk/bin/mxmlc

ENV JAVA_HOME=/usr/lib/jvm/jdk1.7.0_80
ENV FLEX_HOME=/apache-flex-sdk
ENV PATH="${PATH}:${JAVA_HOME}/bin:${FLEX_HOME}/bin"
