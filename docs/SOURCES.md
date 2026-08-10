# Sources and provenance

이 저장소의 reference layer는 프로젝트에서 정리한 Palantir Defense OSDK 공개 자료 기반 CSV를 사용한다.

- `data/source/domains.csv`: Interface 문서의 공개 domain/group 구분을 정규화한 참조 테이블
- `data/source/interfaces.csv`: 공개 Defense OSDK Interface 정리
- `data/source/interface_relations_official.csv`: 검토된 공식 `LINK`, `EXTENDS_TO` 구조

다음은 공식 Palantir predicate가 아니다.

- `data/source/interface_relations_semantic.csv`: 공식 LINK를 설명하기 위해 의미를 부여한 derived predicate
- `data/demo/*`: 전부 설명용 합성 Object/Property/Relationship/Scenario

`Platform Base Interfaces`는 Defense OSDK가 확장 대상으로 참조하는 플랫폼 기반 Interface를 그래프 연결성 때문에 별도 `platform_base_group`으로 보존한 것이며, 6개 Defense OSDK domain/group 중 하나로 간주하지 않는다.
