FROM mcr.microsoft.com/dotnet/core/sdk:3.0 as build
WORKDIR /src

COPY dd-trace-csharp-linux-example.csproj /src/
RUN dotnet restore

COPY Program.cs /src/
RUN dotnet publish -c Release

# Ubuntu 18.04
#FROM mcr.microsoft.com/dotnet/core/runtime:3.0-bionic
#RUN apt-get update && apt-get install -y bash curl

# Debian 9
#FROM mcr.microsoft.com/dotnet/core/runtime:3.0-stretch-slim
#RUN apt-get update && apt-get install -y bash curl

# Alpine
FROM mcr.microsoft.com/dotnet/core/runtime:3.0-alpine3.10
RUN apk --no-cache update && apk add bash curl
RUN apk add libc6-compat gcompat

RUN mkdir -p /opt/datadog
ENV DD_APM_VERSION=1.9.0
RUN curl -L https://github.com/DataDog/dd-trace-dotnet/releases/download/v${DD_APM_VERSION}/datadog-dotnet-apm-${DD_APM_VERSION}.tar.gz | \
    tar xzf - -C /opt/datadog

ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}
ENV CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so
ENV DD_INTEGRATIONS=/opt/datadog/integrations.json
ENV DD_DOTNET_TRACER_HOME=/opt/datadog

RUN curl -L -o /bin/wait-for-it https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /bin/wait-for-it

COPY with-profiler-logs.bash /bin/with-profiler-logs
RUN chmod +x /bin/with-profiler-logs

COPY --from=build /src/bin/Release/netcoreapp3.0/publish/ /app
