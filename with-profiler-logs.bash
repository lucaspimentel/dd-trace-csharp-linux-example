#!/bin/bash
set -euxo pipefail

mkdir -p /var/log/datadog
touch /var/log/datadog/dotnet-profiler.log
tail -f /var/log/datadog/dotnet-profiler.log &
eval "$@"
