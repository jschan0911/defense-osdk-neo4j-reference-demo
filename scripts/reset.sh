#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose down -v --remove-orphans
rm -f runtime/logs/*.log runtime/logs/*.json 2>/dev/null || true
echo "Neo4j volume removed. Run ./scripts/bootstrap.sh to rebuild."
