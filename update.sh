#!/bin/bash
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
docker compose pull
docker compose build --pull
running_services=$(docker compose ps --services | tr $'\n' ' ' | sed -E 's/ +$//')
if [[ "$running_services" != "" ]]; then
  docker compose up -d $running_services
fi
