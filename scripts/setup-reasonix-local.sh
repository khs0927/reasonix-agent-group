#!/usr/bin/env bash
# 로컬 Reasonix + NVIDIA NIM 설정 검증/준비 (README "로컬 실행" 단계)
set -euo pipefail

fail() { echo "ERROR: $*" >&2; exit 1; }

[ -n "${NVIDIA_API_KEY:-}" ] || fail "NVIDIA_API_KEY 환경변수가 필요합니다. export NVIDIA_API_KEY=... 후 재실행하세요."
command -v reasonix >/dev/null 2>&1 || fail "reasonix 바이너리가 없습니다. https://github.com/Reasonix/Reasonix/releases 에서 OS에 맞는 바이너리를 받아 PATH에 두세요."

echo "reasonix: $(reasonix --version 2>&1 | head -n 1)"
echo "NVIDIA NIM endpoint: https://integrate.api.nvidia.com/v1 (model: deepseek-ai/deepseek-v4-flash)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for f in "$SCRIPT_DIR/../configs/reasonix-config.yaml" "$SCRIPT_DIR/../configs/agent-group-agents.yaml"; do
  [ -f "$f" ] || fail "설정 파일 누락: $f"
done

if [ -n "${SMITHERY_API_KEY:-}" ]; then
  echo "khs0927 MCP Toolbox: enabled"
else
  echo "khs0927 MCP Toolbox: disabled (SMITHERY_API_KEY 없음 — MCP 사용 시 설정)"
fi

echo "다음: bash scripts/start-agent-group.sh"
