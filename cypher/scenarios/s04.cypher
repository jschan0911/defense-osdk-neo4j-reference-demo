// S04 — 전투지속지원: 특정 물자를 중심으로 소요·변동·상태·보고 횡단 조회
:param scenarioId => 'S04';

// Q1. 물자소요 중심
MATCH p=(req:Object {id:'OBJ-051'})-[r]->(x:Object)
WHERE r.scenario_id = $scenarioId
RETURN p;

// Q2. 동일 물자유형을 중심으로 소요·입고·재고상태를 횡단 조회
MATCH p=(x:Object)-[r]->(m:Object {id:'OBJ-041'})
WHERE r.scenario_id = $scenarioId
RETURN p;

// Q3. 군수상태 보고서가 참조하는 관측 항목
MATCH p=(report:Object {id:'OBJ-003'})-[r:HAS_OBSERVATION]->(obs:Object)
WHERE r.scenario_id = $scenarioId
RETURN p;

// Q4. 선택 Object의 OSDK 참조 계층 확인
MATCH p=(o:Object)-[:INSTANCE_OF]->(i:Interface)-[:IN_DOMAIN]->(d:Domain)
WHERE $scenarioId IN o.scenario_ids
RETURN p;
