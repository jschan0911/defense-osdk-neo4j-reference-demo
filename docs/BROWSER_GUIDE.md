# Neo4j Browser demo guide

## 권장 시연 순서

### 1. Domain → Interface → Object 계층
`cypher/browser/01_reference_hierarchy.cypher`

설명 포인트: OSDK 공개 참조 구조는 Domain/Interface까지이며, 그 아래 Object는 이해를 위한 합성 데이터다. 저장 방향은 `Object → Interface → Domain`으로 일관되게 위쪽 추상화 계층을 따라간다.

### 2. 공식 OSDK 관계
`cypher/browser/02_interface_official.cypher`

- `EXTENDS_TO`: child → parent 방향
- `LINK`: 물리적으로 한 번 저장하지만 논리적으로 무방향. Browser에 화살표가 보이더라도 storage direction일 뿐 의미 방향이 아니다.

### 3. LINK 의미화
`cypher/browser/03_interface_semantic.cypher`

설명 포인트: `LINK` 자체는 일반 연결이고, `TARGETS_ENTITY`, `ABOUT_SUBJECT` 등은 이 데모에서 해석한 비공식 directional predicate다.

### 4. Object 관계 후보
`cypher/browser/04_candidate_relations.cypher`

설명 포인트: Interface semantic rule과 `EXTENDS_TO` 상속을 이용해 가능한 Object pair를 조회하지만 자동 CREATE하지 않는다.

### 5. 후보와 실제 사실 비교
`cypher/browser/05_actual_vs_candidate.cypher`

설명 포인트: 시나리오에서 실제로 선택된 Object edge가 어떤 Interface rule로 설명 가능한지 대조한다.

### 6. S01~S04
`cypher/scenarios/`의 파일을 순서대로 실행한다.

## Browser caption 권장
- Domain: `name_ko` 또는 `name_en`
- Interface: `name_en`
- Object: `name`

이렇게 설정하면 Label을 업무명으로 오염시키지 않으면서도 화면에는 사람이 읽는 명칭이 표시된다.
