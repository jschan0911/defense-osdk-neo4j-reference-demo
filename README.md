# Defense OSDK → Neo4j Reference Demo

Defense OSDK의 공개 **Domain → Interface → Relationship** 구조를 백엔드·디자인팀에 설명하고, 이를 합성 Object graph에 적용했을 때 어떤 방식으로 활용할 수 있는지 보여주는 Neo4j reference demo입니다.

> 이 저장소는 Palantir Gotham 내부 온톨로지를 복제하지 않습니다. Domain/Interface와 공식 `LINK`, `EXTENDS_TO`는 공개 참조 구조이고, semantic predicate 및 모든 한국형 Object/실제 관계는 설명용 추론·합성 데이터입니다.

## 1. 최종 모델

```text
                         Defense OSDK reference

        [Domain]
            ▲
            │ IN_DOMAIN
            │
       [Interface] ───── LINK ───── [Interface]       // 논리적 무방향
            │   └──── EXTENDS_TO ──> [Interface]      // child -> parent
            │
            ▲
            │ INSTANCE_OF
            │
        [Object] ───── semantic fact ─────> [Object]

                         synthetic demo
```

핵심 원칙은 다음과 같습니다.

- 공개 참조 계층: 6개 Defense OSDK domain/group의 `Domain`, `Interface`, `LINK`, `EXTENDS_TO` (플랫폼 기반 2개 Interface는 별도 reference group으로 보존)
- 합성 데이터: `Object`
- `Object -[:INSTANCE_OF]-> Interface -[:IN_DOMAIN]-> Domain`으로 추상화 방향 통일
- 실제 객체명은 `name` property로 저장하고 `Unit`, `감시중대`, 실제 이름 등을 Object label에 중복 materialize하지 않음
- 공식 `LINK`는 Neo4j에 한 번만 저장하지만 `conceptually_undirected`로 취급
- 의미화 관계는 directional semantic predicate로 별도 보존
- Interface semantic relation은 관계 **후보/검증 규칙**이고, 실제 Object 관계는 시나리오에서 선택한 pair만 생성

## 2. 가장 빠른 실행 — Docker + Neo4j Browser

### 준비
- Docker Desktop 또는 Docker Engine + Compose
- 포트 `7474`, `7687` 사용 가능

### 실행

```bash
cp .env.example .env
python3 scripts/validate_dataset.py
docker compose up -d
```

`loader`가 `cypher/bootstrap/*.cypher`를 파일명 순서대로 실행합니다.

Neo4j Browser:

```text
http://localhost:7474
```

기본 개발용 계정:
- User: `neo4j`
- Password: `.env`의 `NEO4J_PASSWORD`

### 적재 확인

```bash
docker compose ps
docker compose logs loader
./scripts/smoke_check.sh
```

Browser에서:

```cypher
MATCH (d:Domain) RETURN count(d) AS domains;
MATCH (i:Interface) RETURN count(i) AS interfaces;
MATCH (o:Object) RETURN count(o) AS objects;
MATCH (:Object)-[:INSTANCE_OF]->(:Interface) RETURN count(*) AS instanceOf;
```

## 3. Browser 발표 순서

1. `cypher/browser/01_reference_hierarchy.cypher` — Object → Interface → Domain
2. `cypher/browser/02_interface_official.cypher` — 공식 EXTENDS_TO와 논리적 무방향 LINK
3. `cypher/browser/03_interface_semantic.cypher` — LINK 의미화 predicate
4. `cypher/browser/04_candidate_relations.cypher` — Interface rule 기반 Object 관계 후보
5. `cypher/browser/05_actual_vs_candidate.cypher` — 후보와 실제 실증 관계 비교
6. `cypher/scenarios/s01.cypher` ~ `s04.cypher` — 실증 사례

상세한 설명은 [`docs/BROWSER_GUIDE.md`](docs/BROWSER_GUIDE.md)를 참고하세요.

## 4. 프로젝트 구조

```text
defense-osdk-neo4j-reference-demo/
├── README.md
├── NOTICE.md
├── SECURITY.md
├── docker-compose.yml
├── .env.example
├── data/
│   ├── source/
│   │   ├── domains.csv
│   │   ├── interfaces.csv
│   │   ├── interface_relations_official.csv
│   │   └── interface_relations_semantic.csv
│   ├── demo/
│   │   ├── scenarios.csv
│   │   ├── objects.csv
│   │   ├── object_properties.csv
│   │   └── object_relations.csv
│   └── reference/
├── cypher/
│   ├── bootstrap/
│   ├── browser/
│   ├── scenarios/
│   └── validation/
├── docs/
└── scripts/
```

## 5. 데이터 모델 예시

### Domain / Interface

```cypher
(:Interface {
  id:'IF-...',
  name_en:'Unit',
  name_ko:'부대'
})-[:IN_DOMAIN]->(:Domain {
  id:'DOM-ORDER-OF-BATTLE',
  name_en:'Order of Battle'
})
```

### Object

```cypher
(:Object {
  id:'OBJ-034',
  name:'가상 제101감시중대',
  ...
})-[:INSTANCE_OF]->(:Interface {name_en:'Unit'})
```

이전 버전처럼 `:Object:감시중대:Unit:Organization`을 만들지 않습니다. Interface/상속/Domain은 그래프 관계로 명시적으로 탐색합니다.

### 공식 LINK

```cypher
// 물리 저장은 한 번
(:Interface)-[:LINK {directionality:'conceptually_undirected'}]->(:Interface)

// 논리 조회는 무방향
MATCH p=(a:Interface)-[:LINK]-(b:Interface)
RETURN p;
```

### 의미화 관계와 실제 Object fact

```text
Interface:  Target ──TARGETS_ENTITY──> Targetable Entity
Object:     표적화 검토 T-101 ──TARGETS_ENTITY──> 미식별 군용차량 A
```

Interface semantic relation은 가능한 관계를 설명하는 규칙이고, Object edge는 합성 시나리오에서 실제로 선택한 사실입니다.

## 6. 실증 시나리오

- **S01 복합감시 정보융합 → 표적검토**: IMINT/SIGINT/Intelligence가 동일 관심대상을 설명하고 Target으로 연결
- **S02 표적화 계획 → 모의 교전 → 평가**: Target, Effect Solution, Engagement, Assessment 연결
- **S03 작전·부대·편제**: Operation, Unit, hierarchy 구조 탐색
- **S04 전투지속지원 횡단 조회**: 동일 물자를 중심으로 Requirement, Change/Status Event, Organization, Location, Report 연결

상세 설명: [`docs/SCENARIOS.md`](docs/SCENARIOS.md)

## 7. 주의사항

- 실제 한국군 데이터가 아니다.
- 실제 Gotham 고객 환경의 내부 데이터 모델과 1:1 대응을 주장하지 않는다.
- semantic predicate는 공개 LINK를 해석한 데모 모델이며 공식 Palantir relation name이 아니다.
- 외부 공개 GitHub에 올릴 경우 회사 보안/IP 정책을 별도로 확인한다.
