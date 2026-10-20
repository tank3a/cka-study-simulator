# CKA Simulator on kind: Design

Target host: macOS on Apple Silicon (arm64), Docker 28.1 (Docker Desktop VM), kind v0.30.0, kubectl v1.34.1, helm.
Status: design only, not implemented yet. The user's existing files in `../kind/` are left untouched (we reuse ideas from them, not the files).

## 1. Goals and non-goals

- Look and feel close to the real PSI exam: one Linux terminal, several kube contexts, `ssh <node>` to get onto a node, `sudo -i`,
  vim/tmux, and docs only from kubernetes.io. The terminal needs **no internet**. Only image pulls and the one-time asset build go online.
- 15-17 weighted tasks in a 2h timer, graded per check with partial credit, and every task can be re-seeded on its own.
- Non-goal: being a perfect replica. Section 9 lists the gaps honestly.

Verified facts (Oct 2026):
- kind v0.30.0 defaults to `kindest/node:v1.34.0`, and the image is multi-arch with arm64 support.
- Since v0.24.0 kindnet enforces NetworkPolicy out of the box (via sigs.k8s.io/kube-network-policies). One kind issue reports intermittent DNS trouble with it, and another report says policies were not enforced, so bootstrap runs a **negative connectivity self-test** (sec. 8).
- Ingress-NGINX was retired in March 2026. The repo is archived, but images and charts are still available. Ingress tasks stay in the bank because the Ingress API is not retired, but Gateway API is the main target.
- The kind node image is Debian-based, runs **systemd as PID 1**, and ships containerd, crictl, kubeadm, kubelet and kubectl.
- The default kind StorageClass `standard` uses `rancher.io/local-path`. That is the same provisioner as the user's `storageclass.yaml`.

## 2. Topology (laptop-light)

| Cluster (kind name) | Nodes | Context(s) exposed | Purpose |
|---|---|---|---|
| `k8s`  | 1 cp + 2 workers | `k8s`, plus alias contexts `mk8s`, `wk8s` | Most tasks: workloads, scheduling, networking, storage, RBAC, helm, Gateway |
| `ek8s` | 1 cp + 1 worker  | `ek8s` | Destructive node-level tasks: etcd backup/restore, broken kubelet, static pods, broken control plane |
| `ik8s` (on demand) | 1 cp + 1 worker, `disableDefaultCNI: true` | `ik8s` | Install a CNI (Calico) from scratch, kubeadm upgrade (best effort), node join drills |

- **Alias contexts** point at the same cluster but have a different default namespace and user (cert-based users `mk8s-admin` and `wk8s-admin`). They train the "always switch context first" habit and give 5 contexts at the price of 2-3 clusters. The doc says plainly that aliases are not separate clusters.
- Node container names are `k8s-control-plane`, `k8s-worker`, `k8s-worker2`, `ek8s-control-plane`, `ek8s-worker`, and so on. Short ssh aliases are `k8s-cp`, `k8s-node1`, `ek8s-cp`, and so on.

**RAM estimate** (idle, measured ranges reported for kind on arm64; check with `docker stats`):

| Item | RAM |
|---|---|
| kind control-plane node (apiserver + etcd + ctrl-mgr + sched + kubelet) | 550-750 MB |
| kind worker node | 150-300 MB |
| addons on k8s (metrics-server, Gateway controller, local-path) | 150-250 MB |
| exam-term + exam-assets containers | 100-150 MB |
| **Default (k8s + ek8s, 5 nodes)** | **about 2.5-3.5 GB** |
| plus `ik8s` with Calico | +1.0-1.4 GB |

Recommendation: give Docker Desktop 6 GB (8 GB if `ik8s` is used) and 4 CPUs. `exam down ik8s` frees the memory when it is not needed.

## 3. Containers and networking

```
macOS host
 └─ Docker Desktop VM ── docker network "kind" (user-defined bridge, so DNS by container name works)
     ├─ k8s-control-plane / k8s-worker / k8s-worker2   (image cka-sim/node:v1.34.0)
     ├─ ek8s-control-plane / ek8s-worker
     ├─ ik8s-*                                          (on demand)
     ├─ exam-assets   nginx: /charts (helm index), /manifests, /apt (deb repo), /docs-offline (optional)
     │                registry:2 on :5000 (mirror of task images, so the exam needs no internet)
     └─ exam-term     Ubuntu 24.04, user "candidate"; the only place the candidate types
```

- **exam-term** joins the `kind` network, so the internal kubeconfigs (`kind get kubeconfig --internal`, server `https://k8s-control-plane:6443`) work directly. Node IPs and NodePorts are reachable from it, so Gateway, Ingress and Service tasks need no `extraPortMappings`.
- **Real ssh, not a docker exec shim.** A custom node image `cka-sim/node:v1.34.0` is built `FROM kindest/node:v1.34.0` and adds openssh-server, sudo, vim, less, an etcdctl/etcdutl matching the etcd image version, and a user `candidate` with passwordless sudo. `exam-term` has the matching key in `~/.ssh/id_ed25519`, and `~/.ssh/config` maps the short aliases to container names. In the node image, `systemctl enable ssh` hooks sshd into systemd.
- **Fallback** if a custom image is unwanted: the `ssh` wrapper in exam-term becomes `docker exec -it -u candidate <node> bash -l`. This requires mounting `/var/run/docker.sock`, which effectively hands the candidate root on the host Docker. Only the host-side `exam` CLI keeps the socket in the primary design.
- Exam-term has no default route to the internet (`--network kind` plus an iptables egress drop, except to the `kind` subnet). The browser on the Mac is the "docs tab". Using only kubernetes.io is on the honour system.
- Nodes keep internet access for image pulls. Task images are pre-pulled into nodes (`kind load docker-image`) or served from `exam-assets:5000`. A containerd mirror config in the node image lets offline mode work too.

### exam-term image (`images/exam-term/Dockerfile`)
- Ubuntu 24.04 (arm64) with bash, bash-completion, vim, nano, tmux, less, jq, yq (mikefarah, arm64 binary), curl, wget, openssl, openssh-client, iputils-ping, dnsutils, netcat-openbsd, tree and man.
- kubectl v1.34.x, plus `kubectl completion bash`, `alias k=kubectl` and `complete -F __start_kubectl k`. This matches the real exam, which pre-configures `k`.
- helm v3, kustomize (via kubectl), etcdctl + etcdutl v3.6.x (the version kindest/node v1.34 ships), crictl (works only over ssh on nodes, kept for muscle memory) and cfssl (optional).
- `/usr/local/bin/exam` is a symlink to the CLI. `/opt/exam/bank` is mounted **read-only without `solution.md` or `grade.sh`**, and `/var/lib/exam` is a state volume.
- `.vimrc`: `set ts=2 sw=2 expandtab`. Real exam environments vary, so the user can also leave it empty.

## 4. Repository layout

```
simulator/
├── DESIGN.md
├── bin/
│   ├── exam                 # CLI (bash; runs on the host, with a read-only subset inside exam-term)
│   └── sim                  # infra: up | down [cluster] | rebuild | status | doctor
├── images/
│   ├── node/Dockerfile      # FROM kindest/node:v1.34.0 + sshd, sudo, etcdctl, candidate user
│   ├── term/Dockerfile      # exam-term
│   └── assets/              # nginx.conf, build-assets.sh (fetch charts, debs, manifests once)
├── clusters/
│   ├── k8s.yaml  ek8s.yaml  ik8s.yaml   # kind configs (image: cka-sim/node:v1.34.0)
│   └── addons/              # metrics-server.yaml (with --kubelet-insecure-tls), gateway-api-crds.yaml,
│                            # nginx-gateway-fabric.yaml, ingress-nginx-kind.yaml, calico.yaml, cert-manager-crds.yaml
├── lib/
│   ├── common.sh            # ctx(), on_node(), wait_for(), log()
│   ├── assert.sh            # check(), check_eq(), check_jsonpath(), check_node_cmd() ... (sec. 6)
│   └── baseline/            # snapshot of every cluster's healthy state used by resets (sec. 7)
├── bank/
│   └── q01-hpa-autoscale/
│       ├── question.yaml    # metadata (schema, sec. 5)
│       ├── question.md      # text shown to the candidate
│       ├── setup.sh         # idempotent seed; runs with admin kubeconfig + ssh root to nodes
│       ├── grade.sh         # emits checks; never mutates cluster state
│       ├── cleanup.sh       # optional; removes what setup/candidate created (default: delete namespaces)
│       └── solution.md      # reference solution plus a kubernetes.io doc link
├── sets/
│   ├── mock-a.yaml          # ordered list of question ids = one exam (15-17 tasks, weights sum to 100)
│   └── mock-b.yaml
└── state/                   # (host) session.json, results/*.json, logs/
```

## 5. Question schema (`question.yaml`)

```yaml
id: q07-etcd-backup-restore          # unique, also the dir name
title: Back up and restore etcd
domain: cluster-architecture         # storage|troubleshooting|workloads|cluster-architecture|networking
weight: 7                            # percent; set weights should sum to 100
difficulty: hard                     # easy|medium|hard
context: ek8s                        # REQUIRED; shown as "kubectl config use-context ek8s"
host: ek8s-cp                        # optional; node to ssh into (real exam: "ssh cka1234")
namespace: null                      # default namespace for the task, or null
requires: [etcdctl]                  # addons/features: metrics-server|gateway-api|ingress|calico|etcdctl|helm-repo|ik8s
fidelity: high                       # high|partial|low; how faithful kind is (sec. 9)
destructive: true                    # may break the cluster -> reset strategy below
reset: cluster-soft                  # ns | cluster-soft | cluster-hard (sec. 7)
time_hint_min: 10
artifacts:                           # files the candidate must produce, checked by the grader
  - path: /opt/cka/etcd-backup.db
    on: ek8s-cp
checks_total: 4                      # informational; grade.sh is the source of truth
tags: [etcd, static-pod, backup]
```

`question.md` uses placeholders that `exam q` renders: `{{context}}`, `{{namespace}}` and `{{host}}`. The CLI always prints a
header like the real exam's:

```
Question 7 / 16    Weight: 7%    Context: ek8s    Host: ssh ek8s-cp    [FLAGGED]
  -> run first:  kubectl config use-context ek8s
```

## 6. Grading and partial credit

- `grade.sh` sources `lib/assert.sh` and calls one `check` per scoring point. Each check has **points** (default 1). The task score is
  `weight * passed_points / total_points`. This is per-check partial credit, which is how the real exam is generally understood to score. The exact rubric is not public.
- Checks are read-only and use the admin kubeconfig (`--context`), so the candidate's current context does not matter. Node checks go through `ssh root@<node>`.
- Output is one JSON line per check, for example `{"q":"q07","check":"snapshot file exists and is valid","points":1,"pass":true,"detail":"..."}`.
  `exam check` pretty-prints it (PASS/FAIL per check) and saves it to `state/results/q07.json`.

`lib/assert.sh` API:
```
check            "<desc>" [points] -- <cmd...>                      # pass if cmd exits 0
check_eq         "<desc>" [points] "<expected>" -- <cmd...>         # trimmed stdout equality
check_jsonpath   "<desc>" [points] <ctx> <kind/name> -n <ns> '<jsonpath>' "<expected>"
check_node_cmd   "<desc>" [points] <node> -- <cmd...>               # via ssh
check_file       "<desc>" [points] <node|term> <path> [regex]       # existence, optionally content
check_eventually "<desc>" [points] <timeout_s> -- <cmd...>          # retries, e.g. pod Ready
```
Example `grade.sh` (q07):
```bash
source "$LIB/assert.sh"
N=ek8s-control-plane
check_node_cmd "snapshot at /opt/cka/etcd-backup.db is valid" 2 $N -- etcdutl snapshot status /opt/cka/etcd-backup.db
check_node_cmd "etcd static pod uses data-dir /var/lib/etcd-restore" 1 $N -- grep -q 'path: /var/lib/etcd-restore' /etc/kubernetes/manifests/etcd.yaml
check_eventually "apiserver healthy after restore" 1 120 -- kubectl --context ek8s get --raw=/readyz
check_eq "restored state: deployment 'pre-backup' exists, 'post-backup' does not" 2 "pre-backup" -- \
  kubectl --context ek8s -n etcd-test get deploy -o name --no-headers | sed 's#.*/##' | sort
```
Pass mark: 66%, as on the real CKA.

## 7. Environment reset strategy

Three levels, chosen by `question.yaml: reset`:

1. **ns** (most tasks): `cleanup.sh`, or by default delete the labelled namespaces (`exam.q=<id>`) plus cluster-scoped objects carrying
   that label (ClusterRoles, PVs, PriorityClasses, StorageClasses, Gateways, CRDs), then run `setup.sh` again. This takes seconds.
2. **cluster-soft** (node-level edits): restore the node files from the baseline taken by `sim up`. That covers `/etc/kubernetes/manifests/*`,
   `/var/lib/kubelet/config.yaml`, `/etc/systemd/system/kubelet.service.d/*` and `/var/lib/etcd` (tar). Then restart
   kubelet, uncordon, remove taints the task added, and wait for `/readyz` and all nodes Ready. This takes about 30-60 s.
3. **cluster-hard** (upgrade, CNI install, etcd disasters): `kind delete cluster --name X && kind create cluster --config clusters/X.yaml`,
   re-apply addons and reseed, about 60-120 s per cluster. This always applies to `ik8s` after its tasks.

- `setup.sh` must be **idempotent**: `kubectl apply`, plus "if not broken yet, break it". Every object it creates gets the label `exam.q=<id>`.
- `exam start` runs `setup.sh` for **all** tasks in the set before the timer starts, as in the real exam where everything is pre-seeded.
  Tasks on the same cluster must not conflict: unique namespaces per task, and at most one node-breaking task per node per set.
- Baseline snapshot: `sim up` ends with `sim snapshot`. It saves the node file tarballs under `lib/baseline/<cluster>/<node>.tgz` and the
  output of `kubectl get` on cluster-scoped objects, so drift can be detected (`sim doctor`).

## 8. Bootstrap (`sim up`)

1. Build images: `cka-sim/node:v1.34.0`, `cka-sim/term`, `cka-sim/assets` (arm64 native, no emulation).
2. `images/assets/build-assets.sh` runs **online, once**. It packages the helm charts used by tasks into `/charts` with `helm repo index`, and downloads
   the k8s v1.35 arm64 debs (kubeadm, kubelet, kubectl, cri-tools) from pkgs.k8s.io into a flat apt repo `/apt` (for upgrade tasks). It also
   downloads the manifests (Calico, Gateway API CRDs, a Gateway controller, metrics-server, cert-manager CRDs, ingress-nginx for kind) and
   pushes task images into `registry:2`.
3. `kind create cluster --name k8s --config clusters/k8s.yaml`, and the same for ek8s.
4. Addons on k8s: metrics-server (with `--kubelet-insecure-tls`, because kind kubelet certs are self-signed), Gateway API CRDs plus
   NGINX Gateway Fabric (or Envoy Gateway) exposed via NodePort, and the default `standard` local-path SC (already present). Ingress-nginx is optional.
5. Kubeconfig: merge `kind get kubeconfig --internal --name k8s|ek8s`, rename contexts `kind-k8s` to `k8s`, and so on. Add alias contexts
   `mk8s` and `wk8s` (new client certs signed via a CSR and approved, with namespace defaults). Write it to `exam-term:/home/candidate/.kube/config`.
6. NetworkPolicy self-test on k8s: two pods, apply default-deny, and expect `curl` to **fail**. If it succeeds, the script warns and offers to recreate
   k8s with `disableDefaultCNI: true` plus Calico (about 300 MB more RAM).
7. Node apt sources: `/etc/apt/sources.list.d/cka.list` -> `deb [trusted=yes] http://exam-assets/apt ./`, so `apt-get install kubeadm=1.35.*` works offline.
8. `sim snapshot`, then start `exam-term` (`docker run -d --name exam-term --network kind --hostname cka-term ...`).

## 9. Fidelity on kind: what works, what doesn't, mitigations

| Topic | Fidelity | Notes and mitigation |
|---|---|---|
| Workloads, scheduling, taints/affinity, PriorityClass, HPA, RBAC, SA, ConfigMap/Secret, Kustomize, CRD usage | high | Plain API. HPA needs metrics-server (installed). |
| Helm install/upgrade/template | high | Charts from local repo `http://exam-assets/charts`. Tasks say `helm repo add` with that URL. |
| Storage: PV/PVC/SC, reclaim policy, expansion | high/partial | local-path supports `WaitForFirstConsumer`. **Volume expansion is not performed** by local-path, so grade the PVC spec request and `allowVolumeExpansion`, not the resized capacity. |
| Services, DNS, CoreDNS config | high | CoreDNS ConfigMap edits work. |
| NetworkPolicy | high (if self-test passes) | kindnet + kube-network-policies since kind v0.24. Fall back to Calico. |
| Gateway API (HTTPRoute, TLS listener) | high | Controller pre-installed. The grader curls `http://<node-ip>:<nodePort>` from exam-term with a `Host:` header. |
| Ingress | partial | ingress-nginx is retired but still installable. Optional task. |
| CNI install from scratch | high on `ik8s` | `disableDefaultCNI: true`, so nodes start NotReady. The candidate applies Calico (tigera-operator manifest pre-staged in `/opt/manifests` or via the assets URL). Calico images are multi-arch. |
| etcd backup/restore | high | etcd is a kubeadm static pod. Certs in `/etc/kubernetes/pki/etcd/{ca,server}.crt/key`, endpoint `https://127.0.0.1:2379`. Restore with `etcdutl snapshot restore --data-dir /var/lib/etcd-restore`, then edit the hostPath in `etcd.yaml`. Works. Always reset cluster-soft afterwards. |
| Static pods | high | `/etc/kubernetes/manifests` and `staticPodPath` work as on kubeadm. |
| Kubelet troubleshooting | high | systemd is PID 1, so `systemctl status/restart kubelet` and `journalctl -u kubelet` work. Seeds include a wrong `--config`/binary path in the drop-in, a bad `clientCAFile`, kubelet stopped and disabled, and a wrong `staticPodPath`. |
| Broken control plane (bad apiserver flag, wrong etcd cert path, scheduler image typo) | high | Edit the static pod manifests. `crictl ps -a` and `crictl logs` on the node work. |
| cordon/drain/uncordon, node maintenance | high | |
| Certificates: CSR approve, kubeconfig for a new user, `kubeadm certs check-expiration` | high | `kubeadm certs renew` works too, then restart via the manifests. |
| kubeadm upgrade (cp + worker) | **partial / best effort** on `ik8s` | apt from the local repo, `kubeadm upgrade plan/apply v1.35.x` (pulls new control-plane images; nodes have internet, or mirror them into assets), `kubeadm upgrade node`, `apt-get install kubelet`, `systemctl daemon-reload && restart kubelet`. Risks: kind's own kubeadm config and patches, and the containerd and kubelet flags kind sets. If apply fails, the grader still awards credit for the drain/uncordon, kubeadm version and kubelet version checks. Always `cluster-hard` reset afterwards. Has to be tried on a disposable cluster before this task enters a set. |
| kubeadm init/join of a fresh node | low / experimental | A spare `cka-sim/node` container with kubelet not configured, then `kubeadm token create --print-join-command`, then join. kind normally does this step itself, so it may need preflight ignores (`--ignore-preflight-errors=all`). Keep out of default sets. |
| cri-dockerd / container runtime install, sysctl, kernel modules | low | Nodes share the Docker VM kernel. `modprobe` is unavailable and only namespaced sysctls apply. Mitigation: grade the **artifacts** (deb installed from local repo, `systemctl is-enabled cri-docker`, `/etc/sysctl.d/k8s.conf` contents, `sysctl -p` exit code), not runtime behaviour. Label these `fidelity: low`. |
| Swap, reboot persistence, real multi-host networking | not simulated | Restarting a kind node container (`docker restart`) imitates a reboot well enough. |
| Docs restriction / PSI browser | not simulated | Honour system. Optional offline copy of the kubernetes.io docs in `exam-assets/docs-offline`. |

## 10. CLI spec (`bin/exam`)

The session state is `state/session.json`: `{set, started_at, duration_s: 7200, current, flagged:[], results:{qid:{score,max,ts}}}`.

| Command | Behaviour |
|---|---|
| `exam start [set] [--duration 120m] [--no-seed]` | Checks infra (`sim status`), runs `setup.sh` for every question (parallel per cluster), starts the timer, prints Q1. |
| `exam q [n]` | Shows question n (default current) with the header (number, weight, context, host, namespace, flag), then renders `question.md`. Sets current = n. |
| `exam next` / `exam prev` | Moves to the next or previous question and shows it. |
| `exam list` | Table: n, id, weight, context, flagged, last check score. |
| `exam flag [n]` / `exam unflag [n]` | Toggles the review flag. |
| `exam check <n\|all>` | Runs grade.sh and shows per-check PASS/FAIL. **During the timed session only "attempted" is shown; full output appears at `exam end`** (configurable `--practice` to show immediately). |
| `exam reset <n> [--hard]` | Re-seeds one question at its declared reset level (`--hard` escalates). Does not stop the timer. |
| `exam timer` | Remaining time (hh:mm:ss). `exam timer --watch` is a live line for a tmux status pane. Warns at 30, 15 and 5 min. |
| `exam score` | Grades all questions, prints the per-question table, total %, PASS if >= 66%, and the weak domains. |
| `exam end` | Stops the timer, runs `exam score`, archives the session to `state/results/<ts>/`. |
| `exam solution <n>` | Host only. Prints `solution.md`. Refused while the timer is running unless `--force`. |
| `exam practice <id>` | Untimed single-question mode: setup, then work, then check with full output. |

`bin/sim` handles the infra: `up`, `down [cluster|all]`, `up ik8s`, `snapshot`, `doctor` (node Ready, addons, NetPol test, drift vs baseline),
`term` (`docker exec -it -u candidate -w /home/candidate exam-term tmux new -A -s exam`).

Inside exam-term, `exam` talks to the host via a mounted state dir. `q`, `next`, `prev`, `list`, `flag`, `timer` and `check` (results only)
work there, and `setup`/`reset`/`solution` must be run from the host because they need Docker and `solution.md`. Alternative: a tiny host
daemon on a unix socket. Not needed for v1.

## 11. Initial question bank (mock-a, weights = 100)

| # | id | ctx | domain | w | fidelity |
|---|---|---|---|---|---|
| 1 | q01-hpa-autoscale (autoscaling/v2, behavior) | k8s | workloads | 6 | high |
| 2 | q02-priorityclass-preempt | k8s | workloads | 5 | high |
| 3 | q03-sidecar-logging (native sidecar, initContainers restartPolicy: Always) | mk8s | workloads | 5 | high |
| 4 | q04-helm-install-values | k8s | arch | 6 | high |
| 5 | q05-crd-cert-manager-explain (list CRDs, `kubectl explain` to file) | k8s | arch | 4 | high |
| 6 | q06-rbac-sa-clusterrole | wk8s | arch | 5 | high |
| 7 | q07-etcd-backup-restore | ek8s | arch | 7 | high |
| 8 | q08-kubelet-broken-node | ek8s | troubleshooting | 8 | high |
| 9 | q09-apiserver-manifest-fix | ek8s | troubleshooting | 8 | high |
| 10 | q10-pod-pending-resources (requests vs node allocatable) | k8s | troubleshooting | 7 | high |
| 11 | q11-coredns-svc-debug | k8s | troubleshooting | 7 | high |
| 12 | q12-netpol-allow-frontend | k8s | networking | 7 | high |
| 13 | q13-gateway-httproute-tls | k8s | networking | 7 | high |
| 14 | q14-nodeport-expose | mk8s | networking | 6 | high |
| 15 | q15-pvc-storageclass-retain | k8s | storage | 6 | high/partial |
| 16 | q16-static-pod-on-worker | ek8s | arch | 6 | high |
| 17 | q17-calico-install (needs ik8s; mock-b) / q18-kubeadm-upgrade (mock-b, best effort) | ik8s | arch | (mock-b) | high / partial |

mock-a weights sum to 100 (rows 1-16). mock-b swaps in q17/q18 plus a cri-dockerd artifacts task.

## 12. Implementation order

1. `images/node` + `clusters/*.yaml` + `sim up/down`. Verify ssh, systemctl, crictl, etcdctl, and the NetPol self-test on arm64.
2. `images/term` + kubeconfig merge + alias contexts.
3. `lib/assert.sh` + `exam practice` + 3 questions (q01, q07, q08) end to end, including reset.
4. Full CLI (timer, flags, score, session), then the rest of the bank and mock sets.
5. `ik8s` experiments: Calico install, then kubeadm upgrade. Promote q18 only if it passes 3 clean runs.

Verify at implementation time: kindnet NetPol enforcement on this exact kind/node version; sshd under kind's systemd (kind masks some
units); etcd version in kindest/node v1.34.0 (pick a matching etcdctl); whether `kubeadm upgrade apply` tolerates kind's kubeadm config;
NGINX Gateway Fabric arm64 images.
