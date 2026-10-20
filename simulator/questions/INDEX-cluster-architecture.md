# Cluster Architecture, Installation & Configuration: question index (q15..q26)

Weights sum to 73. Offline repo: Helm questions need `http://exam-assets/charts`; q22 publishes chart `cka-web` 1.0.0/1.1.0 into `exam-assets:/charts` itself if missing (best effort, assumes the container path `/charts`, see q22/setup.sh). q23 needs no repo.

| id | title | concept | sub-competency | weight | difficulty | fidelity | doc link |
|---|---|---|---|---|---|---|---|
| q15-rbac-sa-role-binding | Namespaced Role/RoleBinding for a CI ServiceAccount | RBAC (create, SA, can-i) | Manage RBAC | 6 | easy | high | https://kubernetes.io/docs/reference/access-authn-authz/rbac/ |
| q16-rbac-audit-least-privilege | Audit and tighten permissions (ClusterRoleBinding hunt) | RBAC (audit, fix, least privilege) | Manage RBAC | 6 | medium | high | https://kubernetes.io/docs/reference/access-authn-authz/rbac/ |
| q17-etcd-snapshot-backup | Take and verify an etcd snapshot | etcd backup | Manage cluster lifecycle | 6 | medium | high | https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/ |
| q18-etcd-restore-snapshot | Restore etcd from a snapshot (destructive, cluster-soft) | etcd restore | Manage cluster lifecycle | 7 | hard | high | https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/ |
| q19-kubeadm-upgrade-cp-worker | Upgrade control plane and worker (ik8s, cluster-hard) | kubeadm upgrade | Create/manage clusters with kubeadm; lifecycle | 8 | hard | partial | https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/ |
| q20-kubeadm-certs-token-join | Cert expiry report and worker join token | kubeadm certs, token, join | Create/manage clusters with kubeadm | 5 | medium | high | https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/ |
| q21-ha-topology-report | Control plane topology and leader election report | HA control plane, component config (kubeadm-config, lease) | Implement a highly-available control plane | 4 | medium | partial (single-CP kind) | https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/ |
| q22-helm-repo-install-values | Install a chart from the repo with a values file | Helm install/values/repo | Use Helm and Kustomize | 6 | medium | high | https://helm.sh/docs/intro/using_helm/ |
| q23-helm-upgrade-rollback-template | Roll back a broken upgrade, reuse values, helm template | Helm upgrade/rollback/template | Use Helm and Kustomize | 7 | medium | high | https://helm.sh/docs/intro/using_helm/ |
| q24-kustomize-overlay-patch | Production overlay (prefix, namespace, images, generator, patch) | Kustomize | Use Helm and Kustomize | 7 | medium | high | https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/ |
| q25-crd-inspect-create-cr | Inspect CRDs, explain a field, create a validated CR | CRDs and operators | Understand CRDs, operators | 6 | medium | high | https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/ |
| q26-extension-interfaces-cni-csi-cri | Inspect CRI/CNI/CSI facts and create a RuntimeClass | CNI/CSI/CRI extension interfaces | Understand extension interfaces | 5 | medium | partial (kind-specific values) | https://kubernetes.io/docs/concepts/containers/cri/ |

## Concept coverage
12 slots cannot give 9 concepts two dedicated questions each; the pairing below is what is covered (style differs inside each pair).

| concept | questions | styles |
|---|---|---|
| RBAC | q15, q16 | build from scratch / audit and fix |
| etcd backup and restore | q17, q18 | save + verify / restore + manifest edit |
| kubeadm lifecycle | q19, q20 | upgrade drill / certs, token, join command |
| HA control plane | q21 (+ q17 member list, q20 controlPlaneEndpoint concepts) | inspection report |
| Helm | q22, q23 | repo install with values / upgrade, rollback, template |
| Kustomize | q24 only | overlay build. GAP: second Kustomize question not written |
| CRDs and operators | q25 only | inspect + create CR. GAP: no CRD-authoring or controller task |
| CNI/CSI/CRI | q26 (+ q19 apt/kubelet runtime, no CNI install: see DESIGN q17-calico) | inspection + RuntimeClass. GAP: second question |
| Cluster component config | q21 (kubeadm-config), q20 (cert SANs) | partial; kubelet/apiserver config editing belongs to troubleshooting set |

## Set-building notes
- Node-breaking on ek8s: only q18 (cluster-soft). q17, q20, q21 are read-only or write files under /opt/cka and can share ek8s with q18, but the q18 restore replaces etcd data: grade q17/q20/q21 before or accept their state loss by ordering them in a set so q18 comes last when checking.
- q19 uses ik8s and cluster-hard reset; keep it out of default mock sets (partial fidelity).
- All answer files for the term live in /home/candidate/answers/.
