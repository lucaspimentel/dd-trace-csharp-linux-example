FROM mcr.microsoft.com/dotnet/core/sdk:3.0 as build
WORKDIR /src

COPY dd-trace-csharp-linux-example.csproj /src/
RUN dotnet restore

COPY Program.cs /src/
RUN dotnet publish -c Release

# Ubuntu 18.04
FROM mcr.microsoft.com/dotnet/core/runtime:2.1-bionic

# Debian 9
#FROM mcr.microsoft.com/dotnet/core/runtime:2.1-stretch-slim

# Ubuntu, Debian
RUN apt-get update && apt-get install -y bash curl

# Alpine 3.7
#FROM mcr.microsoft.com/dotnet/core/runtime:2.1-alpine3.7

# Alpine 3.9
#FROM mcr.microsoft.com/dotnet/core/runtime:2.1-alpine3.9

# Alpine 3.7 or 3.9
#RUN apk add bash curl libc6-compat

RUN mkdir -p /opt/datadog
RUN curl -L https://github.com/DataDog/dd-trace-dotnet/releases/download/v1.7.0/datadog-dotnet-apm-1.7.0.tar.gz | \
    tar xzf - -C /opt/datadog

ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}
ENV CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so
ENV DD_INTEGRATIONS=/opt/datadog/integrations.json

RUN curl -L -o /bin/wait-for-it https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /bin/wait-for-it

COPY with-profiler-logs.bash /bin/with-profiler-logs
RUN chmod +x /bin/with-profiler-logs

COPY --from=build /src/bin/Release/netcoreapp2.1/publish/ /app
