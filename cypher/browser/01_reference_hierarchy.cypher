// Domain -> Interface -> Object reference hierarchy
// Stored traversal direction is Object -> Interface -> Domain.
MATCH p=(o:Object)-[:INSTANCE_OF]->(i:Interface)-[:IN_DOMAIN]->(d:Domain)
RETURN p
LIMIT 80;
