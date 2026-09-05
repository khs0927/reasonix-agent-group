"""Python 오케스트레이터 (README "개발자 도구"의 import 계약 이행).

사용법 (agent-group/ 디렉토리에서):
    python3 -c "import orchestrator; orchestrator.inject_task('new feature')"
    python3 orchestrator.py run        # 파이프라인 실행
    python3 orchestrator.py validate   # 파일/설정 존재 여부 검증
    python3 orchestrator.py list       # 대기 중인 태스크 목록
"""
from __future__ import annotations

import json
import os
import sys
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(HERE)
TASKS_FILE = os.path.join(HERE, "tasks.json")
PIPELINE_FILE = os.path.join(HERE, "pipeline.yaml")
AGENTS_FILE = os.path.join(REPO_ROOT, "configs", "agent-group-agents.yaml")

NIM_URL = "https://integrate.api.nvidia.com/v1/chat/completions"
NIM_MODEL = "deepseek-ai/deepseek-v4-flash"


def _load_tasks() -> list:
    if not os.path.exists(TASKS_FILE):
        return []
    with open(TASKS_FILE, encoding="utf-8") as fh:
        return json.load(fh)


def _save_tasks(tasks: list) -> None:
    with open(TASKS_FILE, "w", encoding="utf-8") as fh:
        json.dump(tasks, fh, ensure_ascii=False, indent=2)


def inject_task(description: str) -> int:
    """새 태스크를 큐에 주입하고 태스크 id를 반환한다."""
    if not description or not description.strip():
        raise ValueError("description이 비어 있습니다.")
    tasks = _load_tasks()
    task_id = len(tasks)
    tasks.append({"id": task_id, "description": description.strip(), "status": "queued"})
    _save_tasks(tasks)
    print(f"injected task {task_id}: {description.strip()}")
    return task_id


def _require_yaml():
    try:
        import yaml  # type: ignore
    except ImportError:
        raise SystemExit("PyYAML이 필요합니다: pip install pyyaml")
    return yaml


def _load_pipeline() -> list:
    yaml = _require_yaml()
    with open(PIPELINE_FILE, encoding="utf-8") as fh:
        return yaml.safe_load(fh)["stages"]


def _nim_chat(api_key: str, system: str, user: str) -> str:
    payload = json.dumps({
        "model": NIM_MODEL,
        "temperature": 0.1,
        "max_tokens": 4096,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
    }).encode("utf-8")
    req = urllib.request.Request(
        NIM_URL,
        data=payload,
        headers={"Content-Type": "application/json", "Authorization": f"Bearer {api_key}"},
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        body = json.load(resp)
    return body["choices"][0]["message"]["content"]


def run() -> int:
    api_key = os.environ.get("NVIDIA_API_KEY", "")
    if not api_key:
        raise SystemExit("NVIDIA_API_KEY 환경변수가 필요합니다.")
    yaml = _require_yaml()
    with open(AGENTS_FILE, encoding="utf-8") as fh:
        personas = {a["id"]: a for a in yaml.safe_load(fh)["agents"]}
    stages = _load_pipeline()

    tasks = [t for t in _load_tasks() if t["status"] == "queued"]
    if not tasks:
        print("대기 중인 태스크가 없습니다. inject_task()로 먼저 등록하세요.")
        return 0

    for task in tasks:
        print(f"=== task {task['id']}: {task['description']} ===")
        context = task["description"]
        for stage in stages:
            if stage["id"] == "done":
                break
            persona = personas[stage["persona"]]
            system = f"You are {persona['id']} ({persona['role']}). Expertise: {', '.join(persona['expertise'])}."
            user = f"단계 [{stage['id']}: {stage['task']}]를 수행하라. 게이트: {stage['gate']}\n현재까지 맥락:\n{context}"
            print(f"-- stage {stage['id']} ({persona['id']}) 실행 중...")
            result = _nim_chat(api_key, system, user)
            context += f"\n\n[{stage['id']} 결과]\n{result}"
        task["status"] = "done"
        task["result"] = context
        print(f"=== task {task['id']} 완료 ===")
    _save_tasks(_load_tasks_marked(tasks))
    return 0


def _load_tasks_marked(updated: list) -> list:
    tasks = _load_tasks()
    by_id = {t["id"]: t for t in updated}
    return [by_id.get(t["id"], t) for t in tasks]


def validate() -> int:
    ok = True
    for path in (PIPELINE_FILE, AGENTS_FILE, TASKS_FILE if os.path.exists(TASKS_FILE) else None):
        if path is None:
            continue
        exists = os.path.exists(path)
        print(f"{'OK  ' if exists else 'FAIL'} {path}")
        ok = ok and exists
    for name in ("NVIDIA_API_KEY",):
        present = bool(os.environ.get(name))
        print(f"{'OK  ' if present else 'WARN'} env {name} {'설정됨' if present else '미설정 (run 실행 시 필요)'}")
    try:
        _require_yaml()
        stages = _load_pipeline()
        print(f"OK   pipeline stages: {len(stages)}")
    except SystemExit as e:
        print(f"WARN {e} (validate는 계속 진행)")
    return 0 if ok else 1


def list_tasks() -> int:
    tasks = _load_tasks()
    if not tasks:
        print("등록된 태스크가 없습니다.")
        return 0
    for t in tasks:
        print(f"[{t['id']}] {t['status']}: {t['description']}")
    return 0


def main(argv: list) -> int:
    cmd = argv[1] if len(argv) > 1 else "validate"
    if cmd == "run":
        return run()
    if cmd == "validate":
        return validate()
    if cmd == "list":
        return list_tasks()
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
