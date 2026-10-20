# Gap questions: Troubleshooting (q103-q110)

Fills COVERAGE.md gaps for the Troubleshooting domain (8 questions). Solutions are in Korean in `solution.md`.
Sub-competencies: (N) clusters and nodes, (C) cluster components, (M) monitor resource usage, (L) container output streams, (S) services and networking.
ek8s control-plane questions (q103, q104, q107, q108) are all mutually exclusive and also conflict with q37, q39, q40 (one control-plane fault at a time; reset cluster-soft between). q107 uses `seed_order: last` (API down after seeding).
metrics-server questions (q105, q106) modify the shared addon on `k8s`; they conflict with each other and with every task relying on metrics (q09, q14, q49, q50).

| id | title | concept | sub | weight | difficulty | fidelity | doc | conflicts |
|---|---|---|---|---|---|---|---|---|
| q103-controller-manager-crash | No ReplicaSet created, kube-controller-manager crash (flag typo + sa key path) | kube-controller-manager troubleshooting | C | 7 | medium | high | https://kubernetes.io/docs/tasks/debug/debug-cluster/ | q37, q39, q40, q104, q107, q108 |
| q104-controller-manager-disabled | RS and Job make no Pods, `--controllers=*,-replicaset,-job` (Running but inert) | kube-controller-manager troubleshooting | C | 6 | medium | high | https://kubernetes.io/docs/tasks/debug/debug-cluster/ | q37, q39, q40, q103, q107, q108 |
| q105-metrics-server-tls | kubectl top fails: metrics-server missing `--kubelet-insecure-tls` | metrics-server pipeline (APIService) | M | 6 | medium | medium (kind self-signed kubelet certs; real-world fix is proper certs) | https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/ | q50, q09, q14, q49, q106 |
| q106-metrics-apiservice-svc | Metrics API unreachable: Service targetPort mismatch, Pod Ready | metrics-server pipeline (APIService) | M | 6 | medium | high | https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/ | q50, q09, q14, q49, q105 |
| q107-apiserver-authz-keyfile | kube-apiserver crash: bad authorization-mode, missing tls key path | kube-apiserver troubleshooting | C | 8 | hard | high | https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/ | q37, q39, q40, q103, q104, q108 |
| q108-scheduler-flags-probe | Pending Pods: scheduler flag typo, then secure-port vs probe port | kube-scheduler troubleshooting | C | 7 | medium | high | https://kubernetes.io/docs/tasks/debug/debug-cluster/ | q37, q39, q40, q103, q104, q107 |
| q109-exec-multicontainer | kubectl exec -c in a two-container Pod (env, log count, shared localhost) | kubectl exec / port-forward / debug | L | 5 | easy | high | https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/ | none |
| q110-portforward-debug | port-forward to a specific Pod + ephemeral debug container on shell-less Pod | kubectl exec / port-forward / debug | L | 6 | medium | high (`--target` process sharing relies on containerd, works on kind) | https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/ | none |

Weight total: 51. Not run on a cluster: all scripts passed `bash -n` only. Items to verify at first live run: q104 sed insertion of `--controllers=` into the kubeadm manifest, q105/q106 assume the addon Deployment/Service are named `metrics-server` in `kube-system` with container port named `https` and Service `targetPort: https`, q108 startupProbe timing (Pod may show Running 0/1 for a while), q110 `/proc/1/environ` readable via `--target`.
