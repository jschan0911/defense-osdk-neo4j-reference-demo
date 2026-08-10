// 1) Object without exactly one Interface mapping — expected 0
MATCH (o:Object)
OPTIONAL MATCH (o)-[r:INSTANCE_OF]->(:Interface)
WITH o, count(r) AS c
WHERE c <> 1
RETURN o.id AS object_id, o.name AS object, c AS interface_mapping_count;

// 2) Interface without exactly one Domain mapping — expected 0
MATCH (i:Interface)
OPTIONAL MATCH (i)-[r:IN_DOMAIN]->(:Domain)
WITH i, count(r) AS c
WHERE c <> 1
RETURN i.id AS interface_id, i.name_en AS interface, c AS domain_mapping_count;

// 3) Semantic relation accidentally marked official — expected 0
MATCH (:Interface)-[r]->(:Interface)
WHERE r.layer = 'semantic' AND r.official = true
RETURN r;

// 4) Materialized Object relationship unsupported by a semantic rule — expected 0
MATCH (s:Object)-[actual]->(t:Object)
MATCH (s)-[:INSTANCE_OF]->(si:Interface)
MATCH (t)-[:INSTANCE_OF]->(ti:Interface)
OPTIONAL MATCH (si)-[:EXTENDS_TO*0..8]->(sr:Interface)-[rule]->(tr:Interface)<-[:EXTENDS_TO*0..8]-(ti)
WHERE rule.layer = 'semantic' AND type(rule) = type(actual)
WITH s, actual, t, collect(rule) AS matchingRules
WHERE size(matchingRules) = 0
RETURN s.id, type(actual), t.id, actual.basis_interface_relation_id;
