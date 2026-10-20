# Troubleshooting question index (q37-q50)

Domain: troubleshooting (30% of the CKA). Sub-competencies follow the CNCF curriculum:
(N) Troubleshoot clusters and nodes, (C) Troubleshoot cluster components, (M) Monitor cluster and application resource usage,
(L) Manage and evaluate container output streams, (S) Troubleshoot services and networking.
Weights sum to 90 (not a full set; mix with other domains). All solutions are in Korean in `solution.md`.

| id | title | concept | sub-competency | weight | difficulty | fidelity | doc |
|---|---|---|---|---|---|---|---|
| q37-kubelet-stopped | Worker NotReady, kubelet stopped/disabled | node NotReady, systemctl | N | 6 | easy | high | https://kubernetes.io/docs/tasks/debug/debug-cluster/ |
| q38-kubelet-config-broken | kubelet will not start (bad clientCAFile + runtime endpoint typo) | node NotReady, journalctl | N | 7 | hard | high | https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ |
| q39-apiserver-flags-broken | kube-apiserver down (etcd CA path, secure-port) | control plane static pod, crictl logs | C | 8 | hard | high | https://kubernetes.io/docs/tasks/debug/debug-cluster/ |
| q40-scheduler-down | kube-scheduler broken (image tag + kubeconfig path), pods Pending | control plane static pod, events | C | 7 | medium | high | https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/ |
| q41-static-pod-wrong-dir | Static pod manifest in wrong dir + bad image | static pods, staticPodPath, crictl | C | 5 | medium | high | https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ |
| q42-pods-imagepull-crashloop | ImagePullBackOff, CrashLoopBackOff, failing liveness | failing pods, logs/describe | L | 6 | medium | high | https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/ |
| q43-pods-pending-causes | Pending: requests, nodeSelector+taint, missing StorageClass | failing pods (Pending), scheduling | N | 7 | medium | high | https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| q44-service-selector-targetport | Service selector typo and wrong targetPort | service not reachable, endpoints | S | 6 | easy | high | https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/ |
| q45-netpol-ingress-chain | Ingress NetworkPolicy chain web-api-db | NetworkPolicy blocking | S | 7 | medium | high (needs NetPol enforcement) | https://kubernetes.io/docs/concepts/services-networking/network-policies/ |
| q46-coredns-corefile | CoreDNS Corefile typos (zone, forward) | DNS failure | S | 7 | hard | high | https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/ |
| q47-netpol-egress-dns | Egress policy blocks DNS | DNS failure + NetworkPolicy | S | 6 | medium | high (needs NetPol enforcement) | https://kubernetes.io/docs/concepts/services-networking/network-policies/ |
| q48-service-readiness-nodeport | NodePort without endpoints (readiness probe 404, named port) | service not reachable, readiness | S | 6 | medium | high | https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/ |
| q49-logs-events-crictl | Collect logs (-c, --previous), Warning events, top --containers, crictl container ID | container logs/events, crictl | L | 7 | medium | high (needs metrics-server for 1 file) | https://kubernetes.io/docs/concepts/cluster-administration/logging/ |
| q50-kubectl-top-usage | Find CPU/memory hogs with kubectl top and cap limits | resource monitoring | M | 5 | easy | high (needs metrics-server) | https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/ |

## Concept coverage
- Node NotReady / kubelet: q37, q38 (q43 for scheduling side)
- Control plane components: q39 (apiserver), q40 (scheduler). controller-manager is NOT covered (same technique as q40).
- Static pods / crictl: q41, q49 (also q39, q40)
- Failing pods: q42, q43
- Service not reachable: q44, q48
- DNS: q46, q47
- NetworkPolicy blocking: q45, q47
- Logs / events / describe: q42, q49
- Monitoring (`kubectl top`): q50, q49 (one part); only 1.5 questions, the weakest concept.

## Seeding constraints (put into sets accordingly)
- ek8s: q37 (worker kubelet), q39 (apiserver, API down after seeding, `seed_order: last`) and q40 (scheduler) all use `ek8s`.
  q39 conflicts with q37 and q40 (API unavailable / same manifest dir). Use q37 + q40 or q39 alone per set. All use `reset: cluster-soft`.
- k8s: q38 breaks `k8s-worker2` kubelet; q43 taints `k8s-worker` (cleanup.sh untaints); q41/q49 use `k8s-worker`.
- q46 breaks cluster DNS on `k8s`; do not combine with q44/q47/q48 or other tasks that resolve names (graders for q45 use pod IPs, q44 uses ClusterIPs, q48 uses NodePort).
- q45, q47 require NetworkPolicy enforcement (kindnet self-test passed); otherwise the negative checks fail.
- q49 and q50 require metrics-server; q50 CPU burners need ~1 minute for metrics to appear.
- `cleanup.sh` exists where cluster-scoped side effects need undoing (q41, q43, q45, q46, q47).
- Node names used in text: nodes are `k8s-worker`/`k8s-worker2`/`ek8s-worker` (kubectl), ssh aliases `k8s-node1`/`k8s-node2`/`ek8s-node1`/`ek8s-cp`.

## Fidelity notes (honest)
- Node/control-plane questions: kind nodes run systemd and kubeadm static pods, so behaviour matches a real kubeadm cluster. Faults rely on kind's file layout
  (`/var/lib/kubelet/config.yaml`, `kubeadm-flags.env`, standard kubeadm manifests). q38's second fault is silently skipped if `kubeadm-flags.env` does not exist.
- Untested: no cluster was available while writing; scripts were only syntax-checked with `bash -n` (shellcheck not installed). First run in `exam practice` mode should verify each setup/grade.
- q40 assumes the scheduler image reference looks like `registry.k8s.io/kube-scheduler:<tag>`.
- q46 relies on the default kind Corefile containing `kubernetes cluster.local` and `forward . /etc/resolv.conf`.
- q50 memory hog and CPU burners depend on metrics-server scrape timing and the Docker Desktop VM CPU count.
