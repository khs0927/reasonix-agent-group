# 배포 가이드

## 로컬 (iSH/Minis)

```bash
export CLOUD_PROVIDER=hetzner
export SSH_PUBKEY_PATH=~/.ssh/id_ed25519.pub
export NVIDIA_API_KEY=...            # 필수
export SMITHERY_API_KEY=...          # MCP 사용 시
bash scripts/setup-reasonix-local.sh # 전제조건 검증
bash scripts/start-agent-group.sh    # 실행
```

## 원격 (Hetzner VM, 완전 자동화)

```bash
export HCLOUD_TOKEN=...              # Hetzner 사용 시 필수
bash scripts/remote-deploy.sh        # 프로비저닝→복사→systemd 등록→검증
```

결과 엔드포인트: `:8080` Reasonix Web UI, `:5001/v1` NIM 호환 API,
`:8081` MCP Gateway.

## Kubernetes (k3s)

```bash
# 1) nvidia-secret.yaml의 REPLACE_ 값을 실제 키로 교체 (커밋 금지)
# 2) 스킬 ConfigMap 생성:
kubectl create configmap agent-skills --from-file=/var/minis/skills
# 3) 적용:
kubectl apply -f k8s/reasonix-deployment.yaml
kubectl apply -f k8s/nvidia-secret.yaml
kubectl apply -f k8s/skills-configmap.yaml
# 4) 외부 노출이 필요하면 k8s/ingress.yaml의 호스트 수정 후 적용
```
