# MCP 연동 가이드

## Gateway

- 설정: `configs/mcp-gateway.yaml` (포트 8081)
- 실행 중 확인: `bash scripts/verify-deployment.sh` (8081 체크 포함)

## 등록 서버 3종

| 이름 | 전송 | 명령/URL |
|------|------|----------|
| `reasonix-tools` | stdio | `reasonix mcp stdio` |
| `skills` | stdio | `reasonix mcp skills --skills-dir /workspace/skills` |
| `khs0927` | http | `https://mcp.smithery.run/khs0927` (Bearer `${SMITHERY_API_KEY}`) |

## khs0927 Toolbox

100개 도구·9개 서버(README 표 참조: 논문 검색, GitHub, 웹 검색,
Vercel, HuggingFace, 구글 드라이브/시트, 미디어 검색 등).
에이전트 내부 호출 규약은 README "MCP Toolbox 연동" 절의 예시를 따른다.
