# 문제 해결

| 증상 | 원인/조치 |
|------|-----------|
| `NVIDIA_API_KEY 환경변수가 필요합니다` | 키 export 후 재실행 (`setup`·`start` 공통) |
| `reasonix 바이너리가 없습니다` | https://github.com/Reasonix/Reasonix/releases 에서 수동 설치 (자동 다운로드는 미지원) |
| `PyYAML이 필요합니다` | `pip install pyyaml` (orchestrator 실행 시) |
| `hcloud CLI가 없습니다` | https://github.com/hetznercloud/cli 설치 (원격 배포 시) |
| `verify-deployment.sh` FAIL | 해당 포트 서비스 미기동 — `journalctl -u reasonix-agent-group -f` 로 로그 확인 |
| `SMITHERY_API_KEY 없음` 경고 | MCP 미사용 시 무시 가능, 사용 시 export |
| DS2API 관련 오류 | DS2API는 현재 비추천 경로 — NVIDIA NIM 직접 사용으로 전환 |

원격 디버깅 (README "개발자 도구" 절):

```bash
ssh user@host 'journalctl -u reasonix-agent-group -f'
scp user@host:~/workspace/.reasonix-session.json ./
```
