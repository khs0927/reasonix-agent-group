#!/usr/bin/env bash
# 클라우드 VM 프로비저닝 (Hetzner, README "원격 배포" 전제 조건)
set -euo pipefail

fail() { echo "ERROR: $*" >&2; exit 1; }

SERVER_NAME="${SERVER_NAME:-reasonix-agent-group}"
SERVER_TYPE="${SERVER_TYPE:-cx22}"
IMAGE="${IMAGE:-ubuntu-24.04}"
SSH_KEY_NAME="${SSH_KEY_NAME:-default}"

[ -n "${HCLOUD_TOKEN:-}" ] || fail "HCLOUD_TOKEN 환경변수가 필요합니다 (Hetzner 사용 시)."
command -v hcloud >/dev/null 2>&1 || fail "hcloud CLI가 없습니다. https://github.com/hetznercloud/cli 참조."

if hcloud server describe "$SERVER_NAME" >/dev/null 2>&1; then
  echo "기존 서버 재사용: $SERVER_NAME"
else
  hcloud server create --name "$SERVER_NAME" --type "$SERVER_TYPE" --image "$IMAGE" --ssh-key "$SSH_KEY_NAME"
fi

IP="$(hcloud server ip "$SERVER_NAME")"
echo "TARGET_HOST=$IP"
