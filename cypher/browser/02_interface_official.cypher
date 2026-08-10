// A. EXTENDS_TO: child -> parent, directional
MATCH p=(child:Interface)-[:EXTENDS_TO]->(parent:Interface)
RETURN p;

// B. LINK: one physical edge, conceptually undirected
MATCH p=(a:Interface)-[:LINK]-(b:Interface)
RETURN p;
