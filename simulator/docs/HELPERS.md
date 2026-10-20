# Helper library for question authors (stable API)

Files: `lib/common.sh` (shared), `lib/assert.sh` (grading, sources common.sh). Both are plain bash, run **on the macOS host**
(bash 3.2 compatible: no associative arrays, no `${var,,}`).

## How scripts are invoked
The runner executes `bash setup.sh`, `bash grade.sh`, `bash cleanup.sh` with cwd = the question dir and these env vars set:

| var | meaning |
|---|---|
| `SIM_ROOT` | absolute path to `simulator/` |
| `LIB` | `$SIM_ROOT/lib` |
| `QID` | question id, e.g. `q07-etcd-backup-restore` |
| `QDIR` | the question directory |
| `ADMIN_KUBECONFIG` | host-side admin kubeconfig (contexts `k8s`, `ek8s`, `ik8s`); never the candidate's |

First lines of every script:
```bash
set -uo pipefail          # do NOT use set -e in grade.sh (a failing check must not abort)
source "$LIB/common.sh"   # setup.sh / cleanup.sh
source "$LIB/assert.sh"   # grade.sh (also loads common.sh)
```

## Node and context names
Contexts: `k8s`, `ek8s`, `ik8s`. (`mk8s`/`wk8s` are candidate-only aliases of `k8s`; graders always use `k8s`.)
Nodes (docker container names): `k8s-control-plane k8s-worker k8s-worker2 ek8s-control-plane ek8s-worker ik8s-control-plane ik8s-worker`.
Short ssh aliases are accepted everywhere a node is expected: `k8s-cp k8s-node1 k8s-node2 ek8s-cp ek8s-node1 ik8s-cp ik8s-node1`.

## common.sh (setup / cleanup / grade)
| function | does |
|---|---|
| `log msg...` | message to stderr |
| `kc <ctx> <kubectl args...>` | kubectl with admin kubeconfig and `--context <ctx>`. Example: `kc k8s -n web get deploy` |
| `kapply <ctx> [kubectl apply args]` | `kc ctx apply` reading stdin (`kapply k8s -f - <<EOF`); same as `kc k8s apply -f -` |
| `ns_create <ctx> <ns>` | idempotent namespace create, labelled `exam.q=$QID` |
| `label_q <ctx> <kind> <name> [-n ns]` | adds label `exam.q=$QID` to an object (use for cluster-scoped objects so default cleanup removes them) |
| `on_node <node> <cmd args...>` | run as root on a node (docker exec; args are quoted safely). Example: `on_node k8s-cp ls /etc/kubernetes` |
| `node_sh <node> '<script>'` | run a bash script (pipes, redirects allowed) as root on the node; script may also come from stdin if arg omitted |
| `node_put <node> <path> [mode]` | write stdin to a file on the node (creates dirs) |
| `node_get <node> <path>` | cat a file from a node |
| `term_sh '<script>'` | run a bash script in `exam-term` as user `candidate` (used for curl checks and for seeding files in the candidate's home) |
| `term_put <path> [mode]` | write stdin to a file in exam-term (as candidate) |
| `node_ip <node>` | container IP on the kind network (reachable from exam-term, NOT from macOS) |
| `wait_for <timeout_s> -- <cmd...>` | retry cmd every 2s until it succeeds; returns 1 on timeout |
| `wait_ready <ctx> <kind/name> [-n ns] [timeout_s]` | wait for condition Ready/Available |
| `resolve_node <name>` | alias -> container name |
| `svc_nodeport <ctx> <ns> <svc> [idx]` | NodePort of a Service (Gateway API data-plane Service is `<gateway-name>-nginx` in the Gateway's namespace, type NodePort; the port is random, so read it with this helper) |

### setup.sh rules
* Must be idempotent (`kubectl apply`, "break only if not yet broken").
* Label everything with `exam.q=$QID` (ns_create does it; for other objects add `labels: {exam.q: ...}` or call `label_q`).
  The default reset deletes namespaces with that label and cluster-scoped objects with that label (ClusterRole(Binding), PV, StorageClass, PriorityClass, Gateway(Class), CRD, Namespace).
* Use a unique namespace per question (suggest the topic, e.g. `hpa-demo`). Do not touch `kube-system` unless the task is about it.
* The task text must not rely on state that setup does not create.
* Files for the candidate: `term_put /home/candidate/...`; files on nodes: `node_put`.
* Prefer images already pulled by every node: `registry.k8s.io/pause:3.10`, `busybox:1.37`, `nginx:1.27` (see `docs/IMAGES.md` for the list actually preloaded). Nodes have internet in v1, but be frugal.

## assert.sh (grade.sh only)
Each function emits one JSON line on stdout (`{"q":..,"check":..,"points":N,"pass":true|false,"detail":".."}`) and a human line on stderr.
`[points]` is an optional positive integer (default 1) placed right after the description. Checks must **never mutate cluster state**.
Task score = weight * passed_points / total_points.

```
check            "<desc>" [pts] -- <cmd...>                     pass if cmd exits 0 (functions like kc/on_node work)
check_sh         "<desc>" [pts] '<bash snippet>'                snippet evaluated in a subshell on the host (pipes OK, kc/on_node available); pass if exit 0
check_eq         "<desc>" [pts] "<expected>" -- <cmd...>        stdout trimmed (leading/trailing whitespace) == expected
check_match      "<desc>" [pts] "<ERE regex>" -- <cmd...>       stdout matches regex (grep -E)
check_jsonpath   "<desc>" [pts] <ctx> <kind/name> [-n ns] '<jsonpath>' "<expected>"      e.g. check_jsonpath "replicas" 1 k8s deploy/web -n web '{.spec.replicas}' 3
check_node_cmd   "<desc>" [pts] <node> -- <cmd...>              cmd runs as root on node, pass if exit 0
check_node_sh    "<desc>" [pts] <node> '<script>'               same, with a bash script (pipes)
check_file       "<desc>" [pts] <node|term> <path> [ERE regex]  file exists (and content matches regex); "term" = exam-term as candidate
check_eventually "<desc>" [pts] <timeout_s> -- <cmd...>         retries every 2s until exit 0 (pod Ready, apiserver back)
check_http       "<desc>" [pts] <expected_status> <curl args...>  curl run INSIDE exam-term (reaches node IPs + NodePorts, not ClusterIPs); status compared to expected_status (000 = connection failed, e.g. NetworkPolicy block)
check_http_body  "<desc>" [pts] "<ERE regex>" <curl args...>    same, body must match
```
Notes
* In `check_eq` etc. everything after `--` is the command; put `|` pipelines in `check_sh`, not after `--`.
* Pods are tested by `kc k8s exec`: e.g. `check "frontend can reach api" 2 -- kc k8s -n np exec deploy/fe -- wget -qO- -T3 http://api`.
  A negative test (traffic must be blocked): `check "db not reachable from other ns" 2 -- bash -c '! kc k8s -n other exec pod/x -- wget -qO- -T3 http://db.np'` (note: `bash -c` loses shell functions; prefer `check_sh "..." 2 '! kc k8s -n other exec pod/x -- wget -qO- -T3 http://db.np'`).
* Gateway/NodePort: `check_http "route works" 2 200 -H 'Host: app.example.com' http://$(node_ip k8s-worker):30080/`. (`$(...)` is expanded at call time on the host; fine.)
* Candidate-produced files on the term: `check_file "result file" 1 term /home/candidate/out.txt 'expected'`. Files on nodes: `check_file ... ek8s-cp /opt/cka/x.db`.
* Keep grading fast (<30 s total); use check_eventually only where the candidate's change needs time to converge.
* Never rely on the candidate's current context or namespace; always pass the context explicitly.
* Do not print anything else to stdout in grade.sh (stdout is parsed as JSONL). Use `log` (stderr) for debug.

## question.md placeholders
`{{context}}`, `{{namespace}}`, `{{host}}` are rendered by `exam q`. Keep the text in the real-exam style (imperative, explicit names, paths).
Exam-term has: kubectl (alias `k`), helm, etcdctl/etcdutl, jq, yq, vim, tmux, curl, openssl, `ssh <node>` + `sudo -i`.
Offline chart repo URL for helm tasks: `http://exam-assets/charts`; local registry `exam-assets:5000`.
