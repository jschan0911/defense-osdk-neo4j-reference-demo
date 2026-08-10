// 04_load_objects.cypher
// Final model: Object nodes use only the stable :Object label.
// Concrete names are properties; Interface membership is explicit via INSTANCE_OF.
LOAD CSV WITH HEADERS FROM 'file:///demo/objects.csv' AS row
MERGE (o:Object {id: row.object_id})
SET o.name = row.name,
    o.scenario_ids = CASE WHEN trim(row.scenario_ids) = '' THEN [] ELSE split(row.scenario_ids, '|') END,
    o.summary_ko = row.summary_ko,
    o.synthetic = toBoolean(row.synthetic)
WITH o, row
MATCH (i:Interface {id: row.primary_interface_id})
MERGE (o)-[r:INSTANCE_OF]->(i)
SET r.modeling_note = 'Explanatory ABox-like mapping to the public Defense OSDK Interface reference; not a claim about Palantir internal implementation';

// Materialize long-form demo values as physical Object node properties.
LOAD CSV WITH HEADERS FROM 'file:///demo/object_properties.csv' AS row
MATCH (o:Object {id: row.object_id})
WITH o, row,
CASE
  WHEN row.property_type = 'integer' THEN toInteger(row.value_raw)
  WHEN row.property_type = 'double' THEN toFloat(row.value_raw)
  WHEN row.property_type = 'boolean' THEN toBoolean(row.value_raw)
  WHEN row.property_type = 'date' THEN date(row.value_raw)
  WHEN row.property_type = 'timestamp' THEN datetime(row.value_raw)
  ELSE row.value_raw
END AS typedValue
SET o[row.property_key] = typedValue;
