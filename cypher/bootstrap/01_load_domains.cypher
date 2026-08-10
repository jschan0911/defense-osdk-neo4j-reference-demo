// 01_load_domains.cypher
LOAD CSV WITH HEADERS FROM 'file:///source/domains.csv' AS row
MERGE (d:Domain {id: row.domain_id})
SET d.name_en = row.name_en,
    d.name_ko = row.name_ko,
    d.domain_kind = row.domain_kind,
    d.reference_scope = row.reference_scope,
    d.official = toBoolean(row.official),
    d.source = 'Defense OSDK public reference';
