// Compare materialized Object facts with the Interface semantic rule that can justify them.
:param scenarioId => 'S01';

MATCH (s:Object)-[actual]->(t:Object)
WHERE actual.scenario_id = $scenarioId
MATCH (s)-[:INSTANCE_OF]->(si:Interface)
MATCH (t)-[:INSTANCE_OF]->(ti:Interface)
OPTIONAL MATCH (si)-[:EXTENDS_TO*0..8]->(sourceRule:Interface)
OPTIONAL MATCH (ti)-[:EXTENDS_TO*0..8]->(targetRule:Interface)
OPTIONAL MATCH (sourceRule)-[rule]->(targetRule)
WHERE rule.layer = 'semantic' AND type(rule) = type(actual)
RETURN s.name AS source,
       type(actual) AS actual_relation,
       t.name AS target,
       sourceRule.name_en AS semantic_rule_source,
       targetRule.name_en AS semantic_rule_target,
       actual.basis AS materialization_basis;
