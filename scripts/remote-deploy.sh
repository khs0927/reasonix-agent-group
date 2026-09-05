#!/usr/bin/env bash
# Hetzner VM 프로비저닝 + 전체 스택 배포 (README "원격 배포 (완전 자동화)")
set -euo pipefail

fail() { echo "ERROR: $*" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

[ -n "${NVIDIA_API_KEY:-}" ] || fail "NVIDIA_API_KEY 환경변수가 필요합니다."
[ -n "${SSH_PUBKEY_PATH:-}" ] || fail "SSH_PUBKEY_PATH 환경변수가 필요합니다 (예: ~/.ssh/id_ed25519.pub)."
[ -f "$SSH_PUBKEY_PATH" ] || fail "공개키 파일을 찾을 수 없습니다: $SSH_PUBKEY_PATH"

if [ -z "${TARGET_HOST:-}" ]; then
  echo "VM 프로비저닝 중..."
  TARGET_HOST="$(bash "$SCRIPT_DIR/provision-vm.sh" | sed -n 's/^TARGET_HOST=//p' | tail -n 1)"
  [ -n "$TARGET_HOST" ] || fail "VM IP를 확보하지 못했습니다."
fi
echo "TARGET_HOST=$TARGET_HOST"

REMOTE_USER="${REMOTE_USER:-root}"
SSH_OPTS="-o StrictHostKeyChecking=accept-new -o ConnectTimeout=10"

echo "파일 복사 중..."
ssh $SSH_OPTS "$REMOTE_USER@$TARGET_HOST" "mkdir -p ~/workspace/reasonix-agent-group"
scp $SSH_OPTS -r "$REPO_ROOT/scripts" "$REPO_ROOT/configs" "$REPO_ROOT/agent-group" "$REMOTE_USER@$TARGET_HOST:~/workspace/reasonix-agent-group/"

echo "원격 부트스트랩 중..."
ssh $SSH_OPTS "$REMOTE_USER@$TARGET_HOST" "NVIDIA_API_KEY='$NVIDIA_API_KEY' SMITHERY_API_KEY='${SMITHERY_API_KEY:-}' bash -s" <<'REMOTE'
set -euo pipefail
command -v python3 >/dev/null 2>&1 || { apt-get update && apt-get install -y python3; }
cat >/etc/systemd/system/reasonix-agent-group.service <<UNIT
[Unit]
Description=Reasonix Agent Group
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/workspace/reasonix-agent-group
Environment=NVIDIA_API_KEY=${NVIDIA_API_KEY}
Environment=SMITHERY_API_KEY=${SMITHERY_API_KEY:-}
ExecStart=/usr/bin/python3 /root/workspace/reasonix-agent-group/agent-group/orchestrator.py run
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now reasonix-agent-group
REMOTE

echo "배포 검증 중..."
TARGET_HOST="$TARGET_HOST" bash "$SCRIPT_DIR/verify-deployment.sh"
