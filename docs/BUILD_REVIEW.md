# Build review

## 반영된 리팩터링

- Object의 다중/동적 Label 제거
- `Domain` 노드 추가
- `Object -[:INSTANCE_OF]-> Interface -[:IN_DOMAIN]-> Domain` 방향 통일
- 공식 LINK는 1개만 저장 + `conceptually_undirected` 유지
- EXTENDS_TO는 child → parent 유지
- 의미화 semantic predicate는 directional relation으로 유지
- Browser/Scenario query를 새 계층에 맞게 수정

## 정적 검증

`python3 scripts/validate_dataset.py`로 다음을 확인한다.

- Domain/Interface 참조 무결성
- LINK/EXTENDS_TO 방향성 메타데이터
- semantic rule provenance
- Object relation rule support
- scenario membership

## 로컬 런타임 확인

Docker bootstrap, smoke check와 S01~S04 Cypher를 로컬에서 확인했다.

```bash
python3 scripts/validate_dataset.py
docker compose up -d
docker compose logs loader
./scripts/smoke_check.sh
```

Neo4j Browser는 `http://localhost:7474`에서 확인한다.
