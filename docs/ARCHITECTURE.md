# 아키텍처 상세

README의 아키텍처 다이어그램을 글로 풀어쓴 것이다.

## 계층

- **ORCHESTRATOR** — `Planner`(작업 분해·순서), `Provisioner`(VM·클러스터 준비),
  `Agent-Group Manager`(페르소나 실행 관리).
- **EXECUTION LAYER** — 실제 일을 하는 5요소:
  1. Reasonix (Go 단일 바이너리)
  2. NVIDIA NIM API (`deepseek-ai/deepseek-v4-flash`, `https://integrate.api.nvidia.com/v1`)
  3. MCP Gateway (stdio/SSE/HTTP, 포트 8081)
  4. All Skills (`/var/minis/skills` 심링크)
  5. Human-Role Agents (6 페르소나, `configs/agent-group-agents.yaml`)

## 요청 흐름

사용자 문장 1개 → planner가 `github-sync`/`document-generator`/`deploy` 같은
타입 작업으로 분해 → 워커 병렬 실행 (`agent-group/pipeline.yaml` 7단계) →
reviewer 게이트 통과 시에만 최종 보고.

가벼운 단일 명령(`hermes "weather"` 수준)은 오케스트레이터를 타지 않고
NVIDIA로 직접 전달되어 오버헤드가 없다.
