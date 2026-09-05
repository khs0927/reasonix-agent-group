# 페르소나 상세 설명

정의 원본: `configs/agent-group-agents.yaml`. 파이프라인에서의 역할은
`agent-group/pipeline.yaml` 참조.

| ID | 파이프라인 단계 | 하는 일 |
|----|---------------|---------|
| `lead-architect` | architect, done | ADR 작성, 최종 종료 확인 |
| `senior-dev` | dev | 구현 + 단위테스트 (Go/TypeScript/Python, TDD) |
| `devops-engineer` | devops | K8s 매니페스트 + GitOps |
| `security-auditor` | security | 위협모델링 + 스캔 (OWASP, SBOM) |
| `qa-engineer` | qa | 통합테스트 + 벤치마크 |
| `product-owner` | product | 릴리즈노트 + 가이드 |

각 페르소나는 MCP Gateway를 통해 공통 툴을 사용하며, 단계 게이트를
통과하지 못하면 다음 단계로 넘어가지 않는다.
