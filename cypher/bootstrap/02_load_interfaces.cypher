// 02_load_interfaces.cypher
LOAD CSV WITH HEADERS FROM 'file:///source/interfaces.csv' AS row
MERGE (i:Interface {id: row.interface_id})
SET i.name_en = row.name_en,
    i.name_ko = row.name_ko,
    i.role_ko = row.role_ko,
    i.property_source_status = row.property_source_status,
    i.source_url = CASE WHEN trim(row.source_url) = '' THEN null ELSE row.source_url END,
    i.source = 'Defense OSDK public reference',
    i.official = true
WITH i, row
MATCH (d:Domain {id: row.domain_id})
MERGE (i)-[r:IN_DOMAIN]->(d)
SET r.official = d.official,
    r.layer = 'reference',
    r.reference_scope = d.reference_scope;
