// Every materialized Object relationship should be explainable by one semantic Interface rule,
// including EXTENDS_TO inheritance on both endpoints. Expected: 0 rows.
MATCH (s:Object)-[actual]->(t:Object)
MATCH (s)-[:INSTANCE_OF]->(si:Interface)
MATCH (t)-[:INSTANCE_OF]->(ti:Interface)
OPTIONAL MATCH (si)-[:EXTENDS_TO*0..8]->(sr:Interface)-[rule]->(tr:Interface)<-[:EXTENDS_TO*0..8]-(ti)
WHERE rule.layer = 'semantic' AND type(rule) = type(actual)
WITH s, actual, t, collect(rule) AS rules
WHERE size(rules) = 0
RETURN s.id AS source_object, type(actual) AS relation, t.id AS target_object;
