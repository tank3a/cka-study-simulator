# Question index: STORAGE and WORKLOADS & SCHEDULING (q01-q14)

All run on context `k8s` (cluster `k8s`, workers `k8s-worker`, `k8s-worker2`), reset level `ns`. Q12/Q13/Q14 add node labels, and their `cleanup.sh` removes them (Q13/Q14 share `zone` labels, which are harmless). Weights sum to 83.

| id | title | concept | curriculum sub-competency | wt | diff | doc link |
|---|---|---|---|---|---|---|
| q01-pv-pvc-deployment | PV + PVC + Deployment mount (fast-solve walkthrough) | PV, PVC, hostPath, Retain, static binding | Manage PVs and PVCs | 6 | easy | https://kubernetes.io/docs/concepts/storage/persistent-volumes/ |
| q02-storageclass-dynamic | StorageClass + dynamic provisioning | StorageClass, WaitForFirstConsumer, reclaimPolicy, allowVolumeExpansion | Implement storage classes and dynamic volume provisioning | 5 | medium | https://kubernetes.io/docs/concepts/storage/storage-classes/ |
| q03-pv-reclaim-accessmode | Patch reclaim policy, bind ROX claim by selector | reclaim policy, access modes, PV selector, readOnly mount | Configure volume types, access modes and reclaim policies | 6 | medium | https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/ |
| q04-expand-pvc | Expand a PVC | allowVolumeExpansion, PVC resize | Implement storage classes and dynamic volume provisioning | 4 | medium | https://kubernetes.io/docs/concepts/storage/persistent-volumes/#expanding-persistent-volumes-claims |
| q05-volume-types-block | emptyDir/hostPath/configMap volumes + Block claim | volume types, volumeMode Block, classic sidecar (shared emptyDir) | Configure volume types, access modes and reclaim policies | 6 | medium | https://kubernetes.io/docs/concepts/storage/volumes/ |
| q06-pvc-pending-fix | Fix a Pending PVC (class/mode/accessMode mismatch) | binding rules, volumeMode, access modes, storageClassName | Manage PVs and PVCs | 6 | hard | https://kubernetes.io/docs/concepts/storage/persistent-volumes/#binding |
| q07-rollout-rollback | Roll back a stuck rollout, then controlled update | rolling update, rollback, rollout history, strategy | Rolling update and rollbacks | 6 | medium | https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ |
| q08-configmap-secret-deploy | ConfigMap + Secret into a Deployment | ConfigMap, Secret, env, volume, defaultMode | ConfigMaps and Secrets | 5 | medium | https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/ |
| q09-hpa-autoscale | HPA with behavior (missing requests trap) | HPA, requests, stabilization window | Configure workload autoscaling | 6 | medium | https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/ |
| q10-native-sidecar | Native sidecar (initContainers + restartPolicy Always) | sidecar, emptyDir, ConfigMap mount, limits | Self-healing/robust deployments; ConfigMaps | 6 | hard | https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/ |
| q11-priorityclass-resources | PriorityClass (highest-1) + requests/limits | PriorityClass, resources | Pod admission and scheduling (limits, etc.) | 6 | medium | https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/ |
| q12-taints-nodeselector | Taints, tolerations, nodeSelector, node labels | taints, tolerations, nodeSelector, control-plane scheduling | Pod admission and scheduling (node affinity, etc.) | 6 | medium | https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| q13-affinity-tolerations-priority | nodeAffinity + podAntiAffinity + DaemonSet toleration + preemptionPolicy Never | node/pod affinity, tolerations, PriorityClass | Pod admission and scheduling | 8 | hard | https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| q14-topology-spread-hpa | topologySpreadConstraints + rollout strategy + HPA | topology spread, rolling update, HPA, requests | Pod scheduling; rolling update; autoscaling | 7 | hard | https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |

## Concept coverage (each concept appears in at least 2 questions of different style)
- PV/PVC: q01 (create from scratch), q03 (patch + selector), q06 (diagnose and recreate)
- StorageClass/dynamic: q02 (create + use), q04 (enable expansion)
- Access modes / reclaim policy: q03, q06 / q01, q02, q03
- Volume modes (Block): q05, q06
- Expanding PVC: q04 (and the SC flag in q02)
- Rolling update / rollback: q07, q14
- ConfigMaps / Secrets: q08, q10 (and q05 configMap volume)
- HPA: q09, q14
- Sidecar: q10 (native), q05 (classic shared emptyDir)
- Requests/limits: q11, q09, q14, q10
- Taints/tolerations: q12, q13
- nodeSelector/affinity: q12, q13
- PriorityClass: q11, q13
- Topology spread: q14 (affinity-style spreading also in q13 anti-affinity)

## Notes for the runner
- Storage fidelity: local-path does not resize volumes, so q04 grades API objects only; q05/q06 use hostPath PVs with static binding.
- q05 creates a Block PV on a hostPath; this binds at the API level only (no Pod consumes it).
- q09/q14 need metrics-server (`requires`).
- Cluster-scoped objects created by candidates (PV, SC, PriorityClass) are removed by per-question `cleanup.sh`.
- Not shellchecked (shellcheck not installed on the authoring host); all scripts pass `bash -n`.
