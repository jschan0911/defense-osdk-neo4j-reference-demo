// 05_load_object_relations.cypher
// Only curated, scenario-confirmed synthetic Object relationships are materialized.
// Interface semantic relations are candidate/type rules, not automatic all-to-all connections.
LOAD CSV WITH HEADERS FROM 'file:///demo/object_relations.csv' AS row
MATCH (s:Object {id: row.source_object_id})
MATCH (t:Object {id: row.target_object_id})
MERGE (s)-[r:$(row.relation_type) {relationship_id: row.relationship_id}]->(t)
SET r.scenario_id = row.scenario_id,
    r.basis_interface_relation_id = row.basis_interface_relation_id,
    r.basis = row.basis,
    r.description_ko = row.description_ko,
    r.synthetic = toBoolean(row.synthetic),
    r.validation_status = 'DEMO_CONFIRMED';
