// S02 — 표적화 계획과 모의 교전·평가
:param scenarioId => 'S02';

// Q1. 시나리오 전체 Object 관계
MATCH p=(a:Object)-[r]->(b:Object)
WHERE r.scenario_id = $scenarioId
RETURN p;

// Q2. Target -> Effect Solution -> Effector Employment
MATCH p=(t:Object {id:'OBJ-060'})-[:HAS_EFFECT_SOLUTION]->(:Object)-[:HAS_EFFECTOR_EMPLOYMENT]->(:Object)
RETURN p;

// Q3. 모의 교전과 사후평가
MATCH p=(e:Object {id:'OBJ-068'})-[r]->(assessment:Object)
WHERE type(r) STARTS WITH 'HAS_' AND $scenarioId IN assessment.scenario_ids
RETURN p;

// Q4. 선택 Object의 OSDK 참조 계층 확인
MATCH p=(o:Object {id:'OBJ-060'})-[:INSTANCE_OF]->(:Interface)-[:IN_DOMAIN]->(:Domain)
RETURN p;
