// 00_constraints.cypher
// Native DB constraints are intentionally limited to stable node identities.
CREATE CONSTRAINT domain_id_unique IF NOT EXISTS
FOR (d:Domain) REQUIRE d.id IS UNIQUE;

CREATE CONSTRAINT interface_id_unique IF NOT EXISTS
FOR (i:Interface) REQUIRE i.id IS UNIQUE;

CREATE CONSTRAINT object_id_unique IF NOT EXISTS
FOR (o:Object) REQUIRE o.id IS UNIQUE;

CREATE INDEX domain_name_en IF NOT EXISTS
FOR (d:Domain) ON (d.name_en);

CREATE INDEX interface_name_en IF NOT EXISTS
FOR (i:Interface) ON (i.name_en);

CREATE INDEX object_name IF NOT EXISTS
FOR (o:Object) ON (o.name);
