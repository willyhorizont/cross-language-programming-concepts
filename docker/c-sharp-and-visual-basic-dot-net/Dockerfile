FROM debian:trixie AS extractor

ARG FNX_DOTNET=dotnet-sdk-10.0.302-linux-x64.tar.gz

COPY tmp/${FNX_DOTNET} /tmp/

RUN mkdir -p /usr/local/dotnet-sdk && tar -xzf /tmp/${FNX_DOTNET} -C /usr/local/dotnet-sdk

FROM debian:trixie

# https://learn.microsoft.com/en-us/dotnet/core/install/linux-scripted-manual#deb-dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    libicu76 \
    libssl3 \
    libstdc++6 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /usr/local/dotnet-sdk /usr/local/dotnet-sdk

ENV DOTNET_ROOT=/usr/local/dotnet-sdk
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_NOLOGO=true
ENV PATH=${PATH}:$DOTNET_ROOT:$DOTNET_ROOT/tools
