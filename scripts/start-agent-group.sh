#!/usr/bin/env bash
# Agent Group 실행 진입점 (README "Agent Group 실행" 단계)
set -euo pipefail

fail() { echo "ERROR: $*" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

[ -n "${NVIDIA_API_KEY:-}" ] || fail "NVIDIA_API_KEY 환경변수가 필요합니다."
command -v python3 >/dev/null 2>&1 || fail "python3이 필요합니다."
[ -f "$REPO_ROOT/agent-group/orchestrator.py" ] || fail "orchestrator가 없습니다: $REPO_ROOT/agent-group/orchestrator.py"
[ -f "$REPO_ROOT/agent-group/pipeline.yaml" ] || fail "파이프라인 정의가 없습니다: $REPO_ROOT/agent-group/pipeline.yaml"

export NVIDIA_API_KEY
export REASONIX_CONFIG="${REASONIX_CONFIG:-$REPO_ROOT/configs/reasonix-config.yaml}"

echo "Starting agent group (Reasonix Web UI -> http://localhost:8080, MCP Gateway -> http://localhost:8081)"
exec python3 "$REPO_ROOT/agent-group/orchestrator.py" run
