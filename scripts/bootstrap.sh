#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ ! -f .env ]]; then cp .env.example .env; fi
python3 scripts/validate_dataset.py
docker compose up -d
echo "Neo4j starting. Browser: http://localhost:7474"
echo "The loader service imports data automatically after Neo4j becomes healthy."
echo "After loading, run: ./scripts/smoke_check.sh"
