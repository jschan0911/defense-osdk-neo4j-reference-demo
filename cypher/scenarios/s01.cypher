// S01 — 복합감시 정보융합에서 표적검토까지
:param scenarioId => 'S01';

// Q1. 실제로 물리화된 합성 Object 관계
MATCH p=(a:Object)-[r]->(b:Object)
WHERE r.scenario_id = $scenarioId
RETURN p;

// Q2. 시나리오 Object -> Interface -> Domain 계층
MATCH p=(o:Object)-[:INSTANCE_OF]->(i:Interface)-[:IN_DOMAIN]->(d:Domain)
WHERE $scenarioId IN o.scenario_ids
RETURN p;

// Q3. 여러 Intelligence 계열 객체가 동일 관심대상을 가리키는 장면
MATCH p=(info:Object)-[r:ABOUT_SUBJECT]->(entity:Object {id:'OBJ-057'})
WHERE r.scenario_id = $scenarioId
RETURN p;

// Q4. 같은 관심대상이 표적화 검토 Object로 이어지는 장면
MATCH p=(target:Object {id:'OBJ-060'})-[r:TARGETS_ENTITY]->(entity:Object {id:'OBJ-057'})
RETURN p;
