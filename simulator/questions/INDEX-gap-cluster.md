# Gap questions: Cluster Architecture, Installation & Configuration (q69..q91)

23 questions fill the Cluster gaps listed in COVERAGE.md. Weights sum to 123 (these are bank weights, not a set; sets re-balance to 100). Each question has question.yaml, question.md, setup.sh, grade.sh, solution.md (Korean) and, where it creates cluster-scoped or node state, cleanup.sh. Only helpers from docs/HELPERS.md are used; all scripts pass `bash -n`; nothing was run against a cluster.

Doc links come from research/official.md only. official.md lists no dedicated CSR page, so q70 links the RBAC page and q71 the kubectl quick reference (kubectl config section).

| id | title | concept (gap) | sub-competency | weight | difficulty | fidelity | doc link | conflicts |
|---|---|---|---|---|---|---|---|---|
| q69-clusterrole-group-nonresource | ClusterRoles for a group, namespaced reuse, non-resource URL | ClusterRole / ClusterRoleBinding | B1 Manage RBAC | 5 | medium | high | https://kubernetes.io/docs/reference/access-authn-authz/rbac/ | none |
| q70-csr-user-certificate | Issue a client certificate through a CSR | kubeconfig / user credentials (CSR) #1 | B1 Manage RBAC | 6 | medium | high | https://kubernetes.io/docs/reference/access-authn-authz/rbac/ | none |
| q71-kubeconfig-build-user | Build a kubeconfig for an existing user cert | kubeconfig / contexts (CSR) #2 | B1 Manage RBAC | 5 | medium | high | https://kubernetes.io/docs/reference/kubectl/quick-reference/ | none |
| q72-node-prereq-sysctl-modules | Prepare a node (modules, sysctl, swap, cgroup driver) | Node prerequisites | B2 Prepare infrastructure | 4 | medium | low (files graded, kernel not) | https://kubernetes.io/docs/setup/production-environment/container-runtimes/ | none (edits ek8s-worker files; cleanup restores) |
| q73-kubeadm-init-config-file | Write and validate a kubeadm init config | kubeadm init #1 | B3 kubeadm clusters | 6 | medium | partial (no real init) | https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/ | none |
| q74-kubeadm-config-fix-migrate | Fix and migrate a broken kubeadm config | kubeadm init #2 | B3 kubeadm clusters | 5 | medium | partial (no real init) | https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/ | none |
| q75-kubeadm-token-controlplane-join | Token and control-plane join command with certificate key | kubeadm token / join | B3 kubeadm clusters | 5 | medium | high | https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/ | q18, q80 (restore of older snapshot drops token and kubeadm-certs secret: grade first) |
| q76-kubeadm-certs-renew-single | Renew one kubeadm cert and restart the API server | kubeadm certs | B4 Cluster lifecycle | 5 | hard | high | https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/ | q39, q40 (control-plane manifests on ek8s); cluster-soft reset |
| q77-kubeadm-upgrade-plan-runbook | upgrade plan, drain dry-run, worker runbook | kubeadm upgrade | B4 Cluster lifecycle | 4 | medium | partial (no real upgrade; q19 is the drill) | https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/ | none |
| q78-drain-cordon-maintenance | Stale cordon, drain with flags, node stays cordoned | drain / cordon / uncordon | B4 Cluster lifecycle | 6 | medium | high | https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/ | q91 (both touch k8s-worker state; no taint used); changes schedulability of k8s-worker and k8s-worker2, avoid sets with other tasks that need worker2 schedulable |
| q79-etcd-backup-script | Backup script with $1, snapshot status JSON, endpoint status | etcd backup | B4 Cluster lifecycle | 6 | medium | high | https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/ | q18, q80 (shared ek8s etcd; grade before restore) |
| q80-etcd-restore-inplace | Restore etcd in place, no manifest edit | etcd restore | B4 Cluster lifecycle | 7 | hard | high | https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/ | q18 (never in the same set: both replace ek8s etcd data), q17, q75, q79 (grade before restore); cluster-soft reset |
| q81-ha-external-etcd-config | External-etcd HA kubeadm config, quorum facts, leader lease | HA control plane topology | B5 HA control plane | 5 | hard | partial (single-CP kind, design/validate only) | https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/ | none |
| q82-helm-select-version-by-appversion | Pick chart version by appVersion, show values, install with override | Helm install / repo / search | B6 Helm and Kustomize | 5 | medium | high (publishes chart cka-notes into exam-assets best effort, same mechanism as q22) | https://helm.sh/docs/intro/using_helm/ | none (repo name `platform`, q22 uses `cka-charts`) |
| q83-helm-history-rollback-revision | Find first good revision, explicit rollback, get values | Helm upgrade / rollback / history | B6 Helm and Kustomize | 6 | medium | high | https://helm.sh/docs/intro/using_helm/ | none |
| q84-kustomize-fix-overlay-secretgen | Repair broken overlay, secretGenerator without hash | Kustomize | B6 Helm and Kustomize | 6 | medium | high | https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/ | none (ns kz-dev; q24 uses kz-prod) |
| q85-crd-versions-schema-facts | CRD versions/schema facts, fix rejected CR | CRD inspect + CR creation | B8 CRDs and operators | 5 | medium | high | https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/ | none |
| q86-crd-author-database | Author a CRD (enum, default, status, printer column) | CRD authoring #1 | B8 CRDs and operators | 6 | hard | high | https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/ | none |
| q87-operator-install-rbac-leader | Install operator bundle, RBAC for CR + leases | CRD authoring / operator install #2 | B8 CRDs and operators | 6 | hard | partial (Deployment is an nginx stand-in, no reconcile loop) | https://kubernetes.io/docs/concepts/extend-kubernetes/operator/ | none |
| q88-cni-calico-manifest-podcidr | Calico manifest with the cluster pod CIDR | CNI plugin install #1 | B7 Extension interfaces | 7 | hard | partial (needs ik8s and /manifests/calico.yaml staged in exam-assets; untested) | https://kubernetes.io/docs/concepts/cluster-administration/addons/ | q89, q19 (one CNI install per ik8s lifetime); cluster-hard reset |
| q89-cni-calico-operator-installation | Calico via tigera-operator + Installation CR | CNI plugin install #2 | B7 Extension interfaces | 7 | hard | partial (needs ik8s and tigera-operator.yaml/custom-resources.yaml staged; untested) | https://kubernetes.io/docs/concepts/cluster-administration/addons/ | q88, q19; cluster-hard reset |
| q90-csi-driver-storageclass-objects | CSIDriver + StorageClass + CSINode facts | CSI | B7 Extension interfaces | 4 | medium | partial (no real CSI driver on kind; API objects only) | https://kubernetes.io/docs/concepts/storage/volumes/#csi | none |
| q91-runtimeclass-overhead-scheduling | RuntimeClass with overhead and nodeSelector, containerd handlers | CRI / RuntimeClass | B7 Extension interfaces | 4 | medium | partial (only runc handler on kind) | https://kubernetes.io/docs/concepts/containers/cri/ | q78 (soft; labels k8s-worker runtime=sandbox) |

## Gap concept coverage

| concept | questions | style difference |
|---|---|---|
| ClusterRole / ClusterRoleBinding (need 1) | q69 | group subject, ClusterRole reused via RoleBinding, nonResourceURLs (q16 was audit/fix) |
| kubeconfig / CSR (need 2) | q70, q71 | issue cert via CSR / assemble embedded kubeconfig |
| Node prerequisites (need 1) | q72 | persistent files (modules, sysctl, fstab, containerd cgroup) |
| kubeadm init (need 2) | q73, q74 | write config from scratch / repair and migrate |
| kubeadm token / join (need 1) | q75 | control-plane join with certificate key (q20 was worker join) |
| kubeadm certs (need 1) | q76 | renew one cert, restart static pod (q20 was report) |
| kubeadm upgrade (need 1) | q77 | plan + dry-run + runbook on ek8s (q19 is the ik8s drill) |
| drain / cordon (need 1) | q78 | stale cordon, flags, ordering trap |
| etcd backup (need 1) | q79 | reusable script + JSON status |
| etcd restore (need 1) | q80 | stop-the-world in-place restore (q18 changes hostPath) |
| HA topology (need 1) | q81 | external-etcd kubeadm config, quorum math, lease holder |
| Helm install (need 1) | q82 | select version by APP VERSION, show values |
| Helm upgrade/rollback (need 1) | q83 | history forensics and explicit-revision rollback |
| Kustomize (need 1) | q84 | repair broken overlay, secretGenerator |
| CRD inspect (need 1) | q85 | multi-version CRD facts, schema errors |
| CRD authoring / operator (need 2) | q86, q87 | author a CRD / install operator bundle + RBAC |
| CNI install (need 2) | q88, q89 | plain manifest / tigera operator |
| CSI (need 1) | q90 | CSIDriver + StorageClass objects |
| CRI / RuntimeClass (need 1) | q91 | overhead + scheduling fields |

All 23 slots are used; no Cluster gap concept is uncovered. ResourceQuota, LimitRange and PDB are listed in COVERAGE.md under Storage / Workloads, not Cluster, so they were not written here.

## Set-building notes (new conflicts)
- ek8s etcd data: q18 and q80 replace it, so they must not share a set. q17, q75, q79 should be graded before a restore (a restore of an older snapshot removes tokens, the kubeadm-certs secret and backups' objects).
- ek8s-cp control-plane static pods: q76 (cluster-soft) conflicts with q39, q40 (broken apiserver/scheduler manifests). q72 touches only ek8s-worker files, restored by cleanup.
- ik8s: q88 and q89 each install the only CNI and need cluster-hard reset, and q19 expects ik8s with a working CNI. At most one of q19/q88/q89 per set. Both need assets staged at `http://exam-assets/manifests/` (calico.yaml, tigera-operator.yaml, custom-resources.yaml); build-assets.sh must add them (DESIGN sec. 8 step 2 names the manifests but not these file names).
- k8s nodes: q78 cordons/drains k8s-worker2 (cleanup uncordons both); q91 labels k8s-worker. Avoid combining q78 with other tasks that assume worker2 is schedulable.
- New namespaces: cr-a, cr-b, csr-lab, kcfg, drain-lab, etcd-ip, helm-notes, helm-ledger, kz-dev, widget-lab, widget-other, crd-author, ops-system, cni-a, cni-b, csi-lab, rc-lab. Cluster-scoped names created by candidates (ClusterRoles, CSRs `dana`, CRDs, StorageClass `csi-fast`, CSIDriver, RuntimeClass `sandboxed`) are removed by each cleanup.sh.
- Candidate files live under /home/candidate/{answers,csr,creds,kc,crd,kz2,operator,manifests}.
