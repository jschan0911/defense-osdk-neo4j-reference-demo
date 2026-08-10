# Validation

## 정적 데이터 검증

```bash
python3 scripts/validate_dataset.py
```

검증 항목:
- 모든 Interface가 정확한 Domain ID를 참조하는가
- 공식 LINK/EXTENDS_TO endpoint가 존재하는가
- LINK가 `conceptually_undirected`로 표시됐는가
- Semantic relation이 실제 공식 LINK에서 파생됐는가
- 모든 Object가 존재하는 Interface를 참조하는가
- 시나리오 Object 관계가 실제 semantic Interface rule로 설명 가능한가

## Neo4j 내부 검증

`cypher/browser/99_validation.cypher` 또는 `cypher/validation/`을 실행한다.
