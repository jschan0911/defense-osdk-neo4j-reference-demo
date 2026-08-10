# Data model

## Domain

```cypher
(:Domain {
  id: 'DOM-ORDER-OF-BATTLE',
  name_en: 'Order of Battle',
  name_ko: '전투서열',
  domain_kind: 'osdk_domain'
})
```

Defense OSDK의 6개 domain/group은 `:Domain`으로 저장한다. `Platform Base Interfaces`는 Defense OSDK가 상속 대상으로 참조하는 2개 기반 Interface의 연결성을 보존하기 위한 별도 `platform_base_group`이며 공식 OSDK domain으로 간주하지 않는다.

## Interface

```cypher
(:Interface {
  id: 'IF-...',
  name_en: 'Unit',
  name_ko: '부대'
})-[:IN_DOMAIN]->(:Domain)
```

## Object

```cypher
(:Object {
  id: 'OBJ-034',
  name: '가상 제101감시중대',
  ...실제 합성 속성...
})-[:INSTANCE_OF]->(:Interface {name_en:'Unit'})
```

Object에는 `:Unit`, `:감시중대`, 실제 객체명 Label을 추가하지 않는다. Interface와 Domain은 관계를 따라 확인한다.

## Interface relationships

```cypher
(:Interface)-[:EXTENDS_TO]->(:Interface)   // child -> parent
(:Interface)-[:LINK]->(:Interface)         // stored once, conceptually undirected
```

Semantic layer:

```cypher
(:Interface)-[:PERFORMED_BY_UNIT {
  official:false,
  layer:'semantic',
  derived_from:'LINK'
}]->(:Interface)
```

## Object relationships

```cypher
(:Object)-[:PERFORMED_BY_UNIT {
  scenario_id:'S03',
  synthetic:true
}]->(:Object)
```

실제 Object edge는 `data/demo/object_relations.csv`에 지정된 실증 관계만 생성한다.
