# CKA simulator on kind (Apple Silicon / Docker Desktop)

Design: `DESIGN.md`. Author docs: `docs/HELPERS.md`. Honest gaps: `docs/KNOWN_LIMITS.md`.
Prereqs on the Mac: docker (give the VM >= 6 GB), kind, kubectl, helm, jq, python3, internet for the first run.

## 시작 / Quick start
```bash
cd simulator
bin/sim up                 # 이미지 빌드, k8s+ek8s 클러스터, 애드온, exam-term / build images, clusters, addons, terminal (~4 min first time)
bin/sim doctor             # 상태 점검 / health check (nodes, metrics, Gateway, NetworkPolicy, ssh, egress)
bin/exam start mock-a      # 세션 시작 (모든 문제 시드, 120분 타이머) / seed all tasks, start 2h timer
bin/sim term               # 시험 터미널 접속 (tmux) / open the exam terminal
```
Inside the terminal (exam-term, user `candidate`): `exam q`, `exam next`, `exam prev`, `exam list`, `exam flag`, `exam check [n|all]`,
`exam reset [n]`, `exam timer`, `exam score`, `exam end`. `ssh k8s-cp` then `sudo -i` for node work. `k` = kubectl, helm, etcdctl, vim, tmux present.
Contexts: `k8s` (cp+2 workers), `mk8s`, `wk8s` (aliases of k8s, own cert users), `ek8s` (cp+worker, destructive node tasks), `ik8s` (on demand).

## 명령 / Commands
| | |
|---|---|
| `bin/sim up [k8s ek8s ik8s]` / `down [cluster\|all]` | 생성 / 삭제 create / delete (down all removes only simulator containers; registry volume kept) |
| `bin/sim status`, `doctor`, `snapshot`, `recreate <c>`, `rebuild` | 상태, 점검, 기준선 저장, 클러스터 재생성, 이미지 재빌드 |
| `bin/exam start [set\|qid..] [--duration 90m] [--practice] [--no-seed]` | 세션 시작. `--practice` = 즉시 채점 상세 / live feedback |
| `bin/exam practice <qid>` | 한 문제 연습 / single untimed question |
| `bin/exam cleanup` | 직전 세션이 바꾼 것(노드 label/taint, kubelet·매니페스트, CoreDNS 등)을 되돌림. `start`/`practice`가 시작 전에 자동으로 실행 (`--no-clean`으로 끔) / undo the previous session's changes; run automatically by start/practice |
| `exam check/reset/score/end` | exam-term에서도 사용 가능(호스트 데몬 `exam daemon`이 중계) / work from the terminal via the host daemon |
| `bin/exam solution [n] [--force]` | 호스트 전용 / host only, refused while timer runs |
| `bin/mkset <name> [seed]` | 문제은행에서 16문항 세트 생성 / compose a 16-task set from the bank |

Default `exam check` hides details until `exam end` (like the real exam); `--practice` shows them. Score = weight * passed/total points per task, normalised by the set's total weight; pass at 66%.
`ik8s` (CNI/kubeadm drills): `bin/sim up ik8s`, install Calico with `kubectl apply -f http://exam-assets/manifests/calico.yaml`, then `bin/sim down ik8s`.
Offline assets (one-time download) are in `assets-cache/`: `images/assets/build-assets.sh` (`WITH_APT=1` adds k8s v1.35 arm64 debs).
Helm repo for tasks: `http://exam-assets/charts` (webapp 0.1.0/0.2.0, podinfo, cert-manager, nginx-gateway-fabric).

## Layout
`bin/` sim, exam, mkset - `lib/` common.sh assert.sh - `images/` node, term, assets - `clusters/` kind configs - `questions/` bank - `sets/` - `state/` (runtime, gitignored: kubeconfigs, ssh key, baselines, results).

## 웹 학습 대시보드 / Web study dashboard (`bin/web`)
Local-only (127.0.0.1) dashboard: 14-day plan, concept list, per-question page (start / terminal / grade / reset / solution). Python 3 stdlib only, no install.
```bash
bin/web                      # start on http://127.0.0.1:8765, prints a URL with ?token=..., opens the browser on macOS
bin/web --check              # print what was parsed (days, concepts, questions, ttyd) and exit; starts nothing
bin/web --dry-run            # buttons only echo the argv they would run (safe while another agent uses the live sim)
bin/web --port 9000 --ttyd-port 7682 --no-open
```
- Everything is generated at runtime from `../study-guide.md` (section 5 plan table), `../study-notes/<code>.md` (per sub-competency study notes, falls back to study-guide section 3), `questions/COVERAGE.md`, `questions/INDEX.md`, each `question.yaml` and `docs/VERIFICATION.md` (re-read on every request; absent file shows `unverified`, missing question shows `untested`). Nothing is hand-copied.
- Buttons run fixed argv lists on the host: Start = `bin/exam practice <id>`, Grade = `bin/exam check 1`, Reset = `bin/exam reset 1` (Grade/Reset require that the active practice session is this question). Solution is read from `solution.md` and unlocks after Grade or the give-up checkbox.
- Security: bound to 127.0.0.1, Host and Origin checked, a random token per start (open the printed URL once; a cookie is kept) is required for all POST and terminal routes. Question ids are validated against `^q[0-9]{2,3}(-[a-z0-9-]+)?$`.
- Web terminal needs `ttyd`: run `brew install ttyd` yourself (the server never installs anything). It then launches `ttyd -i 127.0.0.1 -p 7681 -b /<random> -W docker exec -it -u candidate -w /home/candidate exam-term tmux new-session -A -s exam` on demand (same attach as `bin/sim term`) and embeds it. Without ttyd the page shows the fallback `bin/sim term`. Requires `bin/sim up` first.
