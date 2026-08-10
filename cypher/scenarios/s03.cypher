// S03 — 작전·부대·편제 구조
:param scenarioId => 'S03';

// Q1. 작전 중심 실증 Object 관계 2-hop
MATCH p=(op:Object {id:'OBJ-027'})-[*1..2]-(x:Object)
WHERE all(r IN relationships(p) WHERE r.scenario_id = $scenarioId)
RETURN p;

// Q2. 수행 부대
MATCH (op:Object {id:'OBJ-027'})-[r:PERFORMED_BY_UNIT]->(u:Object)
WHERE r.scenario_id = $scenarioId
RETURN op.name AS operation, u.name AS unit;

// Q3. 편제 관계 객체 주변
MATCH p=(rel:Object {id:'OBJ-037'})-[r]->(x:Object)
WHERE r.scenario_id = $scenarioId
RETURN p;

// Q4. 작전/부대의 Interface와 Domain 확인
MATCH p=(o:Object)-[:INSTANCE_OF]->(i:Interface)-[:IN_DOMAIN]->(d:Domain)
WHERE o.id IN ['OBJ-027','OBJ-034','OBJ-036']
RETURN p;
