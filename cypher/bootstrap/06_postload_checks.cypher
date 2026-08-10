// 06_postload_checks.cypher
// Structural counts.
MATCH (d:Domain) WITH count(d) AS domains
MATCH (i:Interface) WITH domains, count(i) AS interfaces
MATCH (o:Object) WITH domains, interfaces, count(o) AS objects
MATCH (:Object)-[r:INSTANCE_OF]->(:Interface)
WITH domains, interfaces, objects, count(r) AS instanceOf
MATCH (:Interface)-[r]->(:Interface)
WHERE type(r) <> 'IN_DOMAIN'
WITH domains, interfaces, objects, instanceOf, count(r) AS interfaceRelationships
MATCH (:Object)-[r]->(:Object)
WITH domains, interfaces, objects, instanceOf, interfaceRelationships, count(r) AS objectRelationships
RETURN domains, interfaces, objects, instanceOf, interfaceRelationships,
       objectRelationships;
