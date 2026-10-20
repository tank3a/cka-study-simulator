# Gap questions: STORAGE and WORKLOADS & SCHEDULING (q51-q68)

All on context `k8s`, reset level `ns`. Side effects outside namespaces: q53 labels `k8s-worker` with `disk=ssd` in setup (the candidate labels `k8s-worker2`), removed in its `cleanup.sh`.
q51 creates StorageClasses `grow-sc`, `fixed-sc` (labelled `exam.q`, removed by cleanup). q61/q62 share a stand-in VPA CRD (label `exam.shared=vpa-stub`, created only if no VPA CRD exists, intentionally left in place by cleanup).
Doc links come from `research/official.md`; where official.md lists no dedicated page (StatefulSet, Job/CronJob, PDB, DaemonSet) the nearest listed page is given and the solution says what to search for in the kubernetes.io search box.
Weights sum to 105.

| id | title | concept | sub-competency | wt | diff | fidelity | doc link |
|---|---|---|---|---|---|---|---|
| q51-pvc-expand-two-classes | Expand one of two PVCs (only the right StorageClass may change) | PVC expansion | E3 PVs and PVCs | 5 | medium | partial | https://kubernetes.io/docs/concepts/storage/persistent-volumes/ |
| q52-rollback-to-named-revision | Roll back to a specific revision found in rollout history | ReplicaSet / rollout rollback and history | D1 Deployments, rolling update, rollback | 5 | medium | high | https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ |
| q53-daemonset-nodeselector-rolling | Create a DaemonSet for SSD nodes with a rolling update strategy | DaemonSet | D4 Robust self-healing primitives | 5 | medium | high | https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| q54-statefulset-headless-pvc | Create a StatefulSet with a headless Service and volumeClaimTemplates | StatefulSet | D4 Robust self-healing primitives | 7 | medium | high | https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/ |
| q55-statefulset-partition-retention | Canary a StatefulSet update with a partition and PVC retention policy | StatefulSet | D4 Robust self-healing primitives | 6 | hard | high | https://kubernetes.io/docs/reference/kubectl/generated/kubectl_rollout/ |
| q56-job-parallel-completions | Create a parallel Job with completions, deadline and TTL | Job / CronJob | D4 Robust self-healing primitives | 5 | medium | high | https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/ |
| q57-cronjob-fix-and-trigger | Repair a suspended CronJob and trigger a manual run | Job / CronJob | D4 Robust self-healing primitives | 5 | medium | high | https://kubernetes.io/docs/reference/kubectl/quick-reference/ |
| q58-pdb-percent-allowed | Protect a Deployment with a PDB and read allowed disruptions | PodDisruptionBudget | D4 Robust self-healing primitives | 4 | easy | high | https://kubernetes.io/docs/reference/kubectl/quick-reference/ |
| q59-pdb-blocks-drain-fix | Fix a PDB that blocks every eviction | PodDisruptionBudget | D4 Robust self-healing primitives | 6 | medium | high | https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/ |
| q60-secret-tls-pullsecret-mode | Secrets: tls, docker-registry and generic with file mode and env | Secret (generic, env/volume, defaultMode) | D2 ConfigMaps and Secrets | 7 | medium | high | https://kubernetes.io/docs/concepts/configuration/secret/ |
| q61-vpa-recommend-only | VPA in recommendation-only mode with bounds | VPA | D3 Workload autoscaling | 5 | medium | low | https://kubernetes.io/docs/concepts/workloads/autoscaling/vertical-pod-autoscale/ |
| q62-vpa-fix-targetref-sidecar | Repair a VPA: target, Initial mode, per-container policy | VPA | D3 Workload autoscaling | 5 | hard | low | https://kubernetes.io/docs/concepts/workloads/autoscaling/vertical-pod-autoscale/ |
| q63-limitrange-defaults-reject | LimitRange defaults and a rejected oversized Pod | LimitRange | D5 Pod admission and scheduling | 6 | medium | high | https://kubernetes.io/docs/concepts/policy/limit-range/ |
| q64-limitrange-blocks-deployment | Fix a Deployment whose Pods are rejected by a LimitRange | LimitRange | D5 Pod admission and scheduling | 6 | hard | high | https://kubernetes.io/docs/concepts/policy/limit-range/ |
| q65-resourcequota-compute-deploy | Compute ResourceQuota and make a Deployment fit it | ResourceQuota | D5 Pod admission and scheduling | 6 | medium | high | https://kubernetes.io/docs/concepts/policy/resource-quotas/ |
| q66-resourcequota-object-counts | ResourceQuota on object counts and storage, rejected requests | ResourceQuota | D5 Pod admission and scheduling | 6 | hard | high | https://kubernetes.io/docs/concepts/policy/resource-quotas/ |
| q67-podaffinity-cross-namespace | Pod affinity to colocate, anti-affinity across namespaces | Node/Pod affinity and anti-affinity | D5 Pod admission and scheduling | 7 | hard | high | https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| q68-topology-spread-taint-policy | Fix a topology spread constraint that leaves Pods Pending | Topology spread constraints | D5 Pod admission and scheduling | 6 | hard | high | https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
