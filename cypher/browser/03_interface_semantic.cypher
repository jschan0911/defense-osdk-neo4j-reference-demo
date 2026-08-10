// Directional semantic predicates inferred from official LINK relationships.
MATCH p=(a:Interface)-[r]->(b:Interface)
WHERE r.layer = 'semantic'
RETURN p;
