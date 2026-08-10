// 03_load_interface_relations.cypher
// Official layer: LINK and EXTENDS_TO preserve the reviewed public OSDK structure.
// LINK is physically stored once because Neo4j relationships are directed internally,
// but directionality='conceptually_undirected' means queries should normally use -[:LINK]-.
LOAD CSV WITH HEADERS FROM 'file:///source/interface_relations_official.csv' AS row
MATCH (s:Interface {id: row.source_interface_id})
MATCH (t:Interface {id: row.target_interface_id})
MERGE (s)-[r:$(row.relation_type)]->(t)
SET r.relation_id = row.relation_id,
    r.official = true,
    r.layer = 'official',
    r.directionality = row.directionality,
    r.description_ko = row.description_ko,
    r.source_basis = row.source_basis;

// Semantic layer: directional predicates inferred from official LINK relationships.
// These are explanatory/demo ontology predicates, not official Palantir relation names.
LOAD CSV WITH HEADERS FROM 'file:///source/interface_relations_semantic.csv' AS row
MATCH (s:Interface {id: row.source_interface_id})
MATCH (t:Interface {id: row.target_interface_id})
MERGE (s)-[r:$(row.relation_type)]->(t)
SET r.relation_id = row.relation_id,
    r.official = false,
    r.layer = 'semantic',
    r.relation_name_ko = row.relation_name_ko,
    r.confidence = row.confidence,
    r.derived_from_relation_id = row.derived_from_relation_id,
    r.derived_from = row.derived_from,
    r.description_ko = row.description_ko,
    r.note = row.note;
