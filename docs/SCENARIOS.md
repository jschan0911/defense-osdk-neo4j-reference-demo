# Demo scenarios

모든 Object 이름·위치·ID·상황은 합성 데이터다. 각 시나리오는 Interface semantic rule을 가능한 연결 후보로 사용하고, 실제로 의미가 있다고 설정한 Object pair만 물리화한다.

## S01 — 복합감시 정보융합 → 표적검토

무인기 영상판독(IMINT), 신호정보(SIGINT), 종합 정보판단(Intelligence)이 동일한 `미식별 군용차량 A`를 `ABOUT_SUBJECT`로 가리킨다. 이후 `표적화 검토과업 T-101`이 같은 실체를 `TARGETS_ENTITY`로 연결한다.

효과: 서로 다른 정보 유형이 같은 관심대상으로 모이고, 정보 영역의 실체가 표적화 검토로 이어지는 모습을 한 그래프에서 설명한다. 각 Object에서 `INSTANCE_OF → Interface → IN_DOMAIN → Domain`을 따라가면 어떤 OSDK 개념을 참고했는지도 확인할 수 있다.

## S02 — 표적화 계획 → 모의 교전 → 평가

Target에서 Target Effect Solution과 Effector Employment로 이어지는 계획 구조, Targeting Operation의 표적·구역·권한·지침 참조, 모의 Engagement 이후 여러 Assessment 객체 연결을 보여준다.

효과: Targeting and Fires 영역의 여러 Interface 관계를 실제 합성 Object 흐름으로 구체화한다. 다만 이는 OSDK 관계를 활용한 설명용 시나리오이며 실제 군 업무 절차를 그대로 재현한다는 의미는 아니다.

## S03 — 작전·부대·편제

가상 감시작전이 하위작전, 수행부대, 편제구조와 연결된다. Unit/Organization hierarchy 관련 Interface를 사용한 관계 객체도 함께 보여준다.

효과: 익숙한 작전·부대 구조를 통해 `Operation`, `Unit`, hierarchy 계열 Interface가 실제 그래프에서 어떻게 구체화될 수 있는지 설명한다.

## S04 — 특정 물자를 중심으로 소요·변동·상태·보고 횡단 조회

`감시드론 배터리 팩`을 공통 축으로 Materiel Requirement, Materiel Change Event, Materiel Status Event, Organization, Named Location, Report Observation을 연결한다.

효과: `소요 → 입고 → 재고`라는 단일 인과 순서를 주장하는 것이 아니라, 동일 물자·조직·위치를 중심으로 서로 다른 업무 기록을 횡단 탐색할 수 있음을 보여준다.

## 실행

각 파일의 Q1부터 순서대로 실행한다.

```text
cypher/scenarios/s01.cypher
cypher/scenarios/s02.cypher
cypher/scenarios/s03.cypher
cypher/scenarios/s04.cypher
```
