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

## 8. 로컬 검증

```bash
python3 scripts/validate_dataset.py
bash -n scripts/bootstrap.sh
bash -n scripts/reset.sh
```

Docker E2E 확인 항목은 [`docs/BUILD_REVIEW.md`](docs/BUILD_REVIEW.md)를 참고하세요.

## 9. 실제 실행에서 발견한 문제와 해결

이 프로젝트는 정적 데이터 검증만으로 끝내지 않고 macOS + Colima + Docker Compose v5 + Neo4j `2026.06.0`에서 실제 bootstrap과 Browser 접속까지 확인했다. 그 과정에서 발견한 문제와 현재 적용된 해결은 다음과 같다.

### 9.1 Docker 명령이 없는 경우

Docker Desktop을 사용하거나, macOS에서 경량 런타임인 Colima를 사용할 수 있다.

```bash
brew install colima docker docker-compose
colima start --cpu 2 --memory 4 --disk 20
```

Homebrew의 Compose plugin을 Docker CLI가 찾지 못하면 `~/.docker/config.json`에 다음 경로를 추가한다.

```json
{
  "cliPluginsExtraDirs": [
    "/opt/homebrew/lib/docker/cli-plugins"
  ]
}
```

### 9.2 Neo4j가 `Unrecognized setting ... PASSWORD`로 재시작되는 문제

Neo4j Docker image는 `NEO4J_`로 시작하는 환경변수를 database configuration으로 해석한다. 따라서 `neo4j` 서비스에 health check용 `NEO4J_PASSWORD`를 별도로 넣으면 `PASSWORD`라는 알 수 없는 설정으로 변환돼 시작에 실패한다.

현재 Compose는 인증 설정에는 `NEO4J_AUTH`를 사용하고, health check용 값은 Neo4j 설정으로 해석되지 않는 `DEMO_PASSWORD`라는 이름으로 분리했다.

### 9.3 Neo4j는 시작됐지만 health check 인증이 계속 실패하는 문제

health check에서 `'$${DEMO_PASSWORD}'`처럼 작은따옴표를 사용하면 shell이 변수를 확장하지 않고 문자 그대로 전달한다. 현재 설정은 `"$${DEMO_PASSWORD}"`를 사용해 실제 비밀번호가 `cypher-shell`에 전달되도록 했다.

### 9.4 Loader가 데이터 대신 Bash 환경변수만 출력하는 문제

Docker Compose v5에서는 여러 명령이 들어 있는 scalar `command: >-`가 `bash -lc`에 기대한 단일 script 인자로 전달되지 않고 `Cmd=["set","-e"]`처럼 분리될 수 있었다. 그 결과 loader가 `set`만 실행하고 성공 코드로 종료됐으며, 데이터는 0건이었다.

현재는 `command`를 한 개 문자열을 가진 YAML list로 정의해 전체 script가 하나의 인자로 전달되도록 했다.

### 9.5 Loader에서 `cypher-shell: command not found`가 발생하는 문제

Neo4j image의 `cypher-shell`은 `/var/lib/neo4j/bin`에 있다. Loader entrypoint를 `bash -lc`로 실행하면 login shell이 image의 PATH를 덮어써 실행 파일을 찾지 못할 수 있다. 현재는 `bash -c`를 사용해 image의 PATH를 유지한다.

### 9.6 CSV에는 Object 관계가 54건인데 Neo4j에는 52건만 생성되는 문제

서로 다른 시나리오가 동일한 source/type/target 조합을 별도의 `relationship_id`로 사용할 수 있다. 관계 ID 없이 다음처럼 MERGE하면 두 관계가 하나로 합쳐지고, 나중 시나리오의 속성이 앞선 값을 덮어쓴다.

```cypher
MERGE (s)-[r:$(row.relation_type)]->(t)
```

현재 loader는 `relationship_id`까지 identity에 포함한다.

```cypher
MERGE (s)-[r:$(row.relation_type) {relationship_id: row.relationship_id}]->(t)
```

따라서 S01 11건, S02 21건, S03 11건, S04 11건이 각각 보존되며 총 54건이 생성된다.

### 9.7 모델 변경 후에도 이전 데이터가 남는 문제

Compose project name과 volume name이 같으면 이전 실행의 `neo4j_data`가 재사용된다. CSV나 bootstrap 모델을 변경한 뒤에는 단순 `docker compose down`이 아니라 다음 초기화가 필요하다.

```bash
./scripts/reset.sh
docker compose up -d
```

`reset.sh`는 project container와 named volume을 제거하므로 기존 Neo4j 데이터는 복구되지 않는다.

### 9.8 Loader가 `Exited (0)`로 보이는 것은 정상

Loader는 상시 서비스가 아니라 bootstrap을 한 번 실행하는 작업이다. 다음 상태가 정상이다.

```text
neo4j   Up ... (healthy)
loader  Exited (0)
```

최종 적재 결과는 다음과 같아야 한다.

```text
domains: 7
interfaces: 64
objects: 86
instanceOf: 86
interfaceRelationships: 142
objectRelationships: 54
```
