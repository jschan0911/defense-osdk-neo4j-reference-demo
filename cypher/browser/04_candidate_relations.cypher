// Interface semantic rules generate Object relationship candidates only.
// IMPORTANT: do not CREATE/MERGE all returned pairs.
:param scenarioId => 'S01';

MATCH (s:Object)-[:INSTANCE_OF]->(si:Interface)
WHERE $scenarioId IN s.scenario_ids
MATCH (si)-[:EXTENDS_TO*0..8]->(sourceRule:Interface)
MATCH (sourceRule)-[rule]->(targetRule:Interface)
WHERE rule.layer = 'semantic'
MATCH (t:Object)-[:INSTANCE_OF]->(ti:Interface)
WHERE $scenarioId IN t.scenario_ids AND s <> t
MATCH (ti)-[:EXTENDS_TO*0..8]->(targetRule)
RETURN s.id AS source_id,
       s.name AS source,
       type(rule) AS candidate_relation,
       t.id AS target_id,
       t.name AS target,
       sourceRule.name_en AS rule_source_interface,
       targetRule.name_en AS rule_target_interface,
       rule.confidence AS rule_confidence
ORDER BY candidate_relation, source, target;
