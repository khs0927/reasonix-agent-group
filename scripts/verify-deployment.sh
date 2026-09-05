#!/usr/bin/env bash
# 배포 검증 — README에 명시된 3개 엔드포인트 헬스체크
set -uo pipefail

TARGET_HOST="${TARGET_HOST:-localhost}"
TIMEOUT="${TIMEOUT:-5}"
FAILED=0

check() {
  local name="$1" url="$2"
  if curl -sf --max-time "$TIMEOUT" "$url" >/dev/null 2>&1; then
    echo "OK   $name ($url)"
  else
    echo "FAIL $name ($url)"
    FAILED=1
  fi
}

check "Reasonix Web UI" "http://$TARGET_HOST:8080"
check "NVIDIA NIM 호환 API" "http://$TARGET_HOST:5001/v1"
check "MCP Gateway" "http://$TARGET_HOST:8081"

exit "$FAILED"
