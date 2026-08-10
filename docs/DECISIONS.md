# Modeling decisions

1. **공개 참조 계층은 `Domain → Interface`로 명시한다.** Domain과 Interface는 별도 노드이며 `Interface -[:IN_DOMAIN]-> Domain`으로 저장한다.
2. **그 이하 합성 실체는 `Object` 하나로 둔다.** 별도의 ObjectType 노드나 사용자 정의 실명 Label을 만들지 않는다.
3. **Object와 Interface는 `INSTANCE_OF`로 연결한다.** 실제 합성 객체가 어떤 OSDK Interface 개념에 해당하는지 설명하기 위한 ABox-like 매핑이다.
4. **주요 Label은 `:Domain`, `:Interface`, `:Object`처럼 안정적인 메타 계층에만 사용한다.** `감시중대`, `Unit`, `Organization`, 실제 객체명 등을 Object Label에 중복 materialize하지 않는다.
5. **공식 관계는 `LINK`, `EXTENDS_TO`로 보존한다.** `EXTENDS_TO`는 child → parent 방향을 갖는다.
6. **`LINK`는 Neo4j에 한 번만 저장하되 논리적으로 무방향이다.** 공식 LINK 조회는 원칙적으로 `(a)-[:LINK]-(b)`를 사용하며, 저장 source/target 방향에는 의미를 부여하지 않는다.
7. **LINK의 의미화 predicate는 별도 semantic layer다.** 예: `Target -[:TARGETS_ENTITY]-> Targetable Entity`. `official=false`, `derived_from=LINK`를 보존한다.
8. **Semantic Interface relation은 Object 관계의 후보/타입 규칙이다.** 모든 후보를 자동 연결하지 않는다.
9. **실증 시나리오에서 확인한 합성 Object pair만 실제 edge로 물리화한다.** Interface rule은 그 관계의 근거를 설명·검증하는 데 사용한다.
10. **이 모델은 Palantir 내부 구현 재현이 아니다.** Domain/Interface/LINK/EXTENDS_TO는 공개 참조 구조이고, semantic predicate와 한국형 Object/실제 관계는 설명용 추론·합성 데이터다.
