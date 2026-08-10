#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi
NEO4J_PASSWORD="${NEO4J_PASSWORD:-osdk-demo-2026}"

echo "[smoke] graph counts"
docker compose exec -T neo4j cypher-shell -u neo4j -p "$NEO4J_PASSWORD"   "MATCH (d:Domain) WITH count(d) AS domains MATCH (i:Interface) WITH domains,count(i) AS interfaces MATCH (o:Object) RETURN domains,interfaces,count(o) AS objects;"

echo "[smoke] S01 materialized relationships (expected 11)"
docker compose exec -T neo4j cypher-shell -u neo4j -p "$NEO4J_PASSWORD"   "MATCH (:Object)-[r]->(:Object) WHERE r.scenario_id='S01' RETURN count(r) AS s01Relationships;"
