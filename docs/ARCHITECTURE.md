# Architecture

## 1. 최종 계층

```text
Object  ──INSTANCE_OF──> Interface ──IN_DOMAIN──> Domain
                              │
                              ├──EXTENDS_TO─────────> Interface
                              ├──LINK──────────────── Interface   (논리적 무방향)
                              └──Semantic Predicate─> Interface   (비공식 의미화)

Object ──Semantic Predicate──> Object               (실증 사례의 실제 합성 관계)
```

### 공개 참조 영역
- `Domain`
- `Interface`
- 공식 `LINK`, `EXTENDS_TO`

### 데모/해석 영역
- LINK에서 의미를 추론한 Semantic Predicate
- 한국형 합성 `Object`
- 시나리오에서 실제로 선택한 Object 간 관계

## 2. 왜 이중 Label을 사용하지 않는가

초기 버전은 `:Object:감시중대:Unit`처럼 Object에 스키마명과 Interface명을 함께 materialize했다. 조회 hop은 줄지만, 실제 Object·사용자 정의 타입·OSDK Interface가 하나의 Label 집합에 섞여 설명 비용이 커졌다.

현재 버전은 한두 hop이 늘더라도 개념을 노드와 관계로 분리한다. 따라서 `가상 제101감시중대 → Unit → Order of Battle`이라는 추상화 경로가 명시적으로 보인다.

## 3. LINK 방향성

Neo4j relationship은 물리적으로 방향을 가져야 하므로 LINK도 CSV의 source → target으로 한 번 저장한다. 하지만 `directionality=conceptually_undirected`이며 의미상 방향을 주장하지 않는다.

```cypher
MATCH p=(a:Interface)-[:LINK]-(b:Interface)
RETURN p;
```

반면 `EXTENDS_TO`, semantic predicate, Object fact는 의미상 방향을 유지한다.

## 4. 후보와 실제 관계

```text
Interface Rule
Operation ──PERFORMED_BY_UNIT──> Unit

             ↓ 후보/타입 규칙

Object Fact
가상 감시작전 청명 ──PERFORMED_BY_UNIT──> 가상 제101감시중대
```

Interface rule은 가능한 관계의 범위를 좁혀줄 뿐 모든 Operation과 Unit을 자동으로 연결하지 않는다.
