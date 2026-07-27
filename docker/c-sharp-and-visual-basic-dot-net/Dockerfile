FROM debian:trixie

# https://learn.microsoft.com/en-us/dotnet/core/install/linux-scripted-manual#deb-dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    libicu76 \
    libssl3 \
    libstdc++6 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/dotnet-sdk \
    && curl -L -o /tmp/dotnet-sdk.tar.gz "https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.302/dotnet-sdk-10.0.302-linux-x64.tar.gz" \
    && tar -xzf /tmp/dotnet-sdk.tar.gz -C /usr/local/dotnet-sdk \
    && rm /tmp/dotnet-sdk.tar.gz

ENV DOTNET_ROOT=/usr/local/dotnet-sdk
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_NOLOGO=true
ENV PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
