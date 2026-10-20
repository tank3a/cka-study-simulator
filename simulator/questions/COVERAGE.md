# Concept coverage matrix (q01-q110)

Rebuilt from INDEX.md (q01-q110 merged table), each question's question.yaml (fidelity, weight) and the index concept and sub-competency columns; prompts were spot-checked where the mapping was ambiguous. Target: at least 2 questions per concept; gap = max(0, 2 - count). q00-smoke is excluded. A question counts only if the candidate must perform the concept (an object that merely exists as a fixture does not count). Fidelity codes: H = high, P = partial, L = low, M = medium (q105 only). Source for fidelity is question.yaml.

Totals: 87 concepts. Concepts below 2: 0. Concepts with no high-fidelity question: 11. Questions not counted under any concept: 0 (none).

| concept | sub-competency | domain | question ids (fidelity) | count | high | gap |
|---|---|---|---|---|---|---|
| StorageClass (create/configure, expansion flag, default) | E1 StorageClasses, dynamic provisioning | Storage | q02 H, q04 P, q43 H, q51 P, q90 P | 5 | 2 | - |
| Dynamic provisioning + volumeBindingMode (WaitForFirstConsumer) | E1 StorageClasses, dynamic provisioning | Storage | q02 H, q43 H | 2 | 2 | - |
| PersistentVolume (static, hostPath) | E3 PVs and PVCs | Storage | q01 H, q03 H, q05 H, q06 H | 4 | 4 | - |
| PersistentVolumeClaim (create, bind, selector) | E3 PVs and PVCs | Storage | q01 H, q02 H, q03 H, q04 P, q05 H, q06 H, q43 H, q51 P, q54 H | 9 | 7 | - |
| PVC/PV binding diagnosis (class, mode, size mismatch) | E3 PVs and PVCs | Storage | q06 H, q43 H | 2 | 2 | - |
| Volume types (emptyDir, hostPath, configMap, secret) | E2 Volume types, access modes, reclaim | Storage | q05 H, q08 H, q10 H, q60 H | 4 | 4 | - |
| Access modes (RWO/ROX/RWX/RWOP) | E2 Volume types, access modes, reclaim | Storage | q03 H, q06 H | 2 | 2 | - |
| Reclaim policy (Retain/Delete) | E2 Volume types, access modes, reclaim | Storage | q01 H, q02 H, q03 H | 3 | 3 | - |
| volumeMode Block (raw volumes) | E2 Volume types, access modes, reclaim | Storage | q05 H, q06 H | 2 | 2 | - |
| PVC expansion | E3 PVs and PVCs | Storage | q04 P, q51 P | 2 | 0 | - |
| Pod (standalone, multi-container) | D4 Robust self-healing primitives | Workloads & Scheduling | q03 H, q05 H, q26 P, q109 H | 4 | 3 | - |
| Deployment (create/edit Pod template) | D1 Deployments, rolling update, rollback | Workloads & Scheduling | q01 H, q02 H, q08 H, q10 H, q11 H, q12 H, q13 H, q14 H, q52 H, q64 H, q65 H, q68 H | 12 | 12 | - |
| Rolling update strategy (maxSurge/maxUnavailable) | D1 Deployments, rolling update, rollback | Workloads & Scheduling | q07 H, q14 H, q53 H | 3 | 3 | - |
| ReplicaSet / rollout rollback and history | D1 Deployments, rolling update, rollback | Workloads & Scheduling | q07 H, q52 H | 2 | 2 | - |
| DaemonSet | D4 Robust self-healing primitives | Workloads & Scheduling | q13 H, q53 H | 2 | 2 | - |
| StatefulSet (volumeClaimTemplates, headless Service) | D4 Robust self-healing primitives | Workloads & Scheduling | q54 H, q55 H | 2 | 2 | - |
| Job / CronJob | D4 Robust self-healing primitives | Workloads & Scheduling | q56 H, q57 H | 2 | 2 | - |
| Probes (liveness/readiness/startup) | D4 Robust self-healing primitives | Workloads & Scheduling | q42 H, q48 H | 2 | 2 | - |
| Sidecar and init containers | D4 Robust self-healing primitives | Workloads & Scheduling | q05 H, q10 H | 2 | 2 | - |
| PodDisruptionBudget | D4 Robust self-healing primitives | Workloads & Scheduling | q58 H, q59 H | 2 | 2 | - |
| ConfigMap | D2 ConfigMaps and Secrets | Workloads & Scheduling | q05 H, q08 H, q10 H, q24 H | 4 | 4 | - |
| Secret (generic, env/volume, defaultMode) | D2 ConfigMaps and Secrets | Workloads & Scheduling | q08 H, q60 H | 2 | 2 | - |
| HPA | D3 Workload autoscaling | Workloads & Scheduling | q09 H, q14 H | 2 | 2 | - |
| VPA | D3 Workload autoscaling | Workloads & Scheduling | q61 L, q62 L | 2 | 0 | - |
| Resource requests/limits | D5 Pod admission and scheduling | Workloads & Scheduling | q09 H, q10 H, q11 H, q14 H, q43 H, q50 H, q63 H, q64 H, q65 H | 9 | 9 | - |
| LimitRange | D5 Pod admission and scheduling | Workloads & Scheduling | q63 H, q64 H | 2 | 2 | - |
| ResourceQuota | D5 Pod admission and scheduling | Workloads & Scheduling | q65 H, q66 H | 2 | 2 | - |
| Taints and tolerations | D5 Pod admission and scheduling | Workloads & Scheduling | q12 H, q13 H, q43 H | 3 | 3 | - |
| nodeSelector and node labels | D5 Pod admission and scheduling | Workloads & Scheduling | q12 H, q43 H, q53 H | 3 | 3 | - |
| Node/Pod affinity and anti-affinity | D5 Pod admission and scheduling | Workloads & Scheduling | q13 H, q67 H | 2 | 2 | - |
| Topology spread constraints | D5 Pod admission and scheduling | Workloads & Scheduling | q14 H, q68 H | 2 | 2 | - |
| PriorityClass / preemption | D5 Pod admission and scheduling | Workloads & Scheduling | q11 H, q13 H | 2 | 2 | - |
| Role / RoleBinding (incl. can-i verification) | B1 Manage RBAC | Cluster Architecture | q15 H, q16 H | 2 | 2 | - |
| ClusterRole / ClusterRoleBinding | B1 Manage RBAC | Cluster Architecture | q16 H, q69 H | 2 | 2 | - |
| ServiceAccount | B1 Manage RBAC | Cluster Architecture | q15 H, q16 H | 2 | 2 | - |
| kubeconfig / contexts / user credentials (CSR) | B1 Manage RBAC | Cluster Architecture | q70 H, q71 H | 2 | 2 | - |
| Node prerequisites (runtime, kubeadm/kubelet packages, sysctl) | B2 Prepare infrastructure for a cluster | Cluster Architecture | q19 P, q72 L | 2 | 0 | - |
| kubeadm init / cluster bootstrap | B3 Create and manage clusters using kubeadm | Cluster Architecture | q73 P, q74 P | 2 | 0 | - |
| kubeadm token / join | B3 Create and manage clusters using kubeadm | Cluster Architecture | q20 H, q75 H | 2 | 2 | - |
| kubeadm certs (check-expiration, renew, openssl) | B4 Manage cluster lifecycle | Cluster Architecture | q20 H, q76 H | 2 | 2 | - |
| kubeadm upgrade | B4 Manage cluster lifecycle | Cluster Architecture | q19 P, q77 P | 2 | 0 | - |
| drain / cordon / uncordon | B4 Manage cluster lifecycle | Cluster Architecture | q19 P, q78 H | 2 | 1 | - |
| etcd backup (snapshot save/status) | B4 Manage cluster lifecycle | Cluster Architecture | q17 H, q79 H | 2 | 2 | - |
| etcd restore | B4 Manage cluster lifecycle | Cluster Architecture | q18 H, q80 H | 2 | 2 | - |
| HA control plane topology (stacked/external, leases, etcd members) | B5 Highly-available control plane | Cluster Architecture | q21 P, q81 P | 2 | 0 | - |
| Helm install / repo / search | B6 Helm and Kustomize | Cluster Architecture | q22 H, q82 H | 2 | 2 | - |
| Helm upgrade / rollback / history | B6 Helm and Kustomize | Cluster Architecture | q23 H, q83 H | 2 | 2 | - |
| Helm values and template | B6 Helm and Kustomize | Cluster Architecture | q22 H, q23 H, q82 H, q83 H | 4 | 4 | - |
| Kustomize | B6 Helm and Kustomize | Cluster Architecture | q24 H, q84 H | 2 | 2 | - |
| CRD inspect + custom resource creation | B8 CRDs and operators | Cluster Architecture | q25 H, q85 H | 2 | 2 | - |
| CRD authoring / operator install | B8 CRDs and operators | Cluster Architecture | q86 H, q87 P | 2 | 1 | - |
| CNI (inspect config, podCIDR) | B7 Extension interfaces (CNI/CSI/CRI) | Cluster Architecture | q26 P, q36 H | 2 | 1 | - |
| CNI plugin install (Calico/Cilium manifest) | B7 Extension interfaces (CNI/CSI/CRI) | Cluster Architecture | q88 P, q89 P | 2 | 0 | - |
| CSI (provisioner/driver, CSIDriver) | B7 Extension interfaces (CNI/CSI/CRI) | Cluster Architecture | q26 P, q90 P | 2 | 0 | - |
| CRI / RuntimeClass | B7 Extension interfaces (CNI/CSI/CRI) | Cluster Architecture | q26 P, q91 P | 2 | 0 | - |
| Pod networking model (podCIDR, Pod-to-Pod reachability) | C1 Connectivity between Pods | Services & Networking | q26 P, q36 H | 2 | 1 | - |
| NetworkPolicy ingress | C2 Network Policies | Services & Networking | q29 H, q45 H | 2 | 2 | - |
| NetworkPolicy egress (incl. DNS) | C2 Network Policies | Services & Networking | q30 H, q47 H | 2 | 2 | - |
| Service ClusterIP | C3 Service types and endpoints | Services & Networking | q27 H, q28 H, q44 H | 3 | 3 | - |
| Service NodePort | C3 Service types and endpoints | Services & Networking | q27 H, q48 H, q93 P | 3 | 2 | - |
| Service LoadBalancer | C3 Service types and endpoints | Services & Networking | q92 P, q93 P | 2 | 0 | - |
| Endpoints / EndpointSlice (selector, targetPort, named port) | C3 Service types and endpoints | Services & Networking | q28 H, q44 H, q48 H | 3 | 3 | - |
| Headless / ExternalName Services and DNS records | C3 Service types and endpoints | Services & Networking | q54 H, q94 H, q95 H | 3 | 3 | - |
| kube-proxy | C3 Service types and endpoints | Services & Networking | q96 P, q97 H | 2 | 1 | - |
| Gateway / GatewayClass (listeners, TLS) | C4 Gateway API | Services & Networking | q32 H, q98 H | 2 | 2 | - |
| HTTPRoute (path/header match, redirect, backendRefs) | C4 Gateway API | Services & Networking | q31 H, q32 H, q33 H, q98 H, q99 H | 5 | 5 | - |
| Ingress to Gateway migration | C4 Gateway API | Services & Networking | q33 H, q99 H | 2 | 2 | - |
| Ingress resource (rules, TLS, pathType) | C5 Ingress | Services & Networking | q34 P, q99 H, q100 P | 3 | 1 | - |
| Ingress controller / IngressClass | C5 Ingress | Services & Networking | q101 P, q102 P | 2 | 0 | - |
| CoreDNS Corefile (forward, rewrite) | C6 CoreDNS | Services & Networking | q35 H, q46 H | 2 | 2 | - |
| Pod DNS resolution and failure diagnosis (dnsPolicy, nslookup) | C6 CoreDNS | Services & Networking | q36 H, q46 H, q47 H | 3 | 3 | - |
| kubelet / NotReady node (systemctl, journalctl) | A1 Troubleshoot clusters and nodes | Troubleshooting | q37 H, q38 H | 2 | 2 | - |
| kubelet config file and runtime endpoint | A1 Troubleshoot clusters and nodes | Troubleshooting | q38 H, q41 H | 2 | 2 | - |
| crictl | A1 Troubleshoot clusters and nodes | Troubleshooting | q39 H, q40 H, q41 H, q49 H | 4 | 4 | - |
| Static Pod (manifest dir, mirror Pod) | A2 Troubleshoot cluster components | Troubleshooting | q18 H, q39 H, q40 H, q41 H | 4 | 4 | - |
| kube-apiserver troubleshooting | A2 Troubleshoot cluster components | Troubleshooting | q39 H, q107 H | 2 | 2 | - |
| kube-scheduler troubleshooting | A2 Troubleshoot cluster components | Troubleshooting | q40 H, q108 H | 2 | 2 | - |
| kube-controller-manager troubleshooting | A2 Troubleshoot cluster components | Troubleshooting | q103 H, q104 H | 2 | 2 | - |
| Service reachability diagnosis (selector, targetPort, readiness) | A5 Troubleshoot services and networking | Troubleshooting | q28 H, q44 H, q48 H | 3 | 3 | - |
| NetworkPolicy blocking diagnosis | A5 Troubleshoot services and networking | Troubleshooting | q45 H, q47 H | 2 | 2 | - |
| kubectl top (pods, nodes, containers) | A3 Monitor cluster and application resource usage | Troubleshooting | q49 H, q50 H, q105 M | 3 | 2 | - |
| metrics-server pipeline diagnosis (APIService) | A3 Monitor cluster and application resource usage | Troubleshooting | q105 M, q106 H | 2 | 1 | - |
| kubectl logs (-c, --previous) | A4 Manage and evaluate container output streams | Troubleshooting | q42 H, q49 H | 2 | 2 | - |
| kubectl events / describe | A4 Manage and evaluate container output streams | Troubleshooting | q40 H, q43 H, q49 H | 3 | 3 | - |
| kubectl exec / port-forward / debug | A4 Manage and evaluate container output streams | Troubleshooting | q109 H, q110 H | 2 | 2 | - |
| Pod failure diagnosis (ImagePull, CrashLoop, exit codes) | A4 Manage and evaluate container output streams | Troubleshooting | q42 H, q49 H | 2 | 2 | - |
| Pending Pod diagnosis (resources, taints, PVC) | A4 Manage and evaluate container output streams | Troubleshooting | q06 H, q43 H | 2 | 2 | - |

Sub-competency check: all 27 sub-competencies map to at least one concept row: yes.

## Concepts still below 2 (gap)

None. Every concept has at least 2 questions.

## Concepts with no high-fidelity question

These meet the count of 2 but only at partial or low fidelity, so they are verified only as far as the kind lab can represent them.

- PVC expansion (E3): q04 P, q51 P
- VPA (D3): q61 L, q62 L
- Node prerequisites (runtime, kubeadm/kubelet packages, sysctl) (B2): q19 P, q72 L
- kubeadm init / cluster bootstrap (B3): q73 P, q74 P
- kubeadm upgrade (B4): q19 P, q77 P
- HA control plane topology (stacked/external, leases, etcd members) (B5): q21 P, q81 P
- CNI plugin install (Calico/Cilium manifest) (B7): q88 P, q89 P
- CSI (provisioner/driver, CSIDriver) (B7): q26 P, q90 P
- CRI / RuntimeClass (B7): q26 P, q91 P
- Service LoadBalancer (C3): q92 P, q93 P
- Ingress controller / IngressClass (C5): q101 P, q102 P

## Concepts with some but not all high-fidelity questions

- StorageClass (create/configure, expansion flag, default) (E1): 2 of 5 high (q02 H, q04 P, q43 H, q51 P, q90 P)
- PersistentVolumeClaim (create, bind, selector) (E3): 7 of 9 high (q01 H, q02 H, q03 H, q04 P, q05 H, q06 H, q43 H, q51 P, q54 H)
- Pod (standalone, multi-container) (D4): 3 of 4 high (q03 H, q05 H, q26 P, q109 H)
- drain / cordon / uncordon (B4): 1 of 2 high (q19 P, q78 H)
- CRD authoring / operator install (B8): 1 of 2 high (q86 H, q87 P)
- CNI (inspect config, podCIDR) (B7): 1 of 2 high (q26 P, q36 H)
- Pod networking model (podCIDR, Pod-to-Pod reachability) (C1): 1 of 2 high (q26 P, q36 H)
- Service NodePort (C3): 2 of 3 high (q27 H, q48 H, q93 P)
- kube-proxy (C3): 1 of 2 high (q96 P, q97 H)
- Ingress resource (rules, TLS, pathType) (C5): 1 of 3 high (q34 P, q99 H, q100 P)
- kubectl top (pods, nodes, containers) (A3): 2 of 3 high (q49 H, q50 H, q105 M)
- metrics-server pipeline diagnosis (APIService) (A3): 1 of 2 high (q105 M, q106 H)

## Concept counts by domain

- Storage: 10 concepts, 35 question-concept links, 0 below 2, 1 with no high-fidelity question
- Workloads & Scheduling: 22 concepts, 68 question-concept links, 0 below 2, 1 with no high-fidelity question
- Cluster Architecture: 23 concepts, 48 question-concept links, 0 below 2, 7 with no high-fidelity question
- Services & Networking: 16 concepts, 41 question-concept links, 0 below 2, 2 with no high-fidelity question
- Troubleshooting: 16 concepts, 39 question-concept links, 0 below 2, 0 with no high-fidelity question

## Concepts that cannot be exercised faithfully on kind

- kubeadm init, kubeadm upgrade, kubeadm join, node prerequisites (apt packages, container runtime install, sysctl/swap): kind nodes are containers built from a fixed node image. q19 needs the separate ik8s lab with apt and a cluster-hard reset. q73, q74 (init config), q77 (upgrade plan) and q72 (node prep) are file/API-level only; the kernel and real init or join are not run.
- CNI plugin install (Calico/Cilium): the lab CNI is kindnet. q88 and q89 need ik8s (default CNI disabled) and staged manifests; both are untested on a live cluster.
- CSI driver: the default rancher.io/local-path provisioner is not a CSI driver. q90 and q26 grade names and objects only.
- PVC expansion: local-path does not resize volumes; q04 and q51 grade API objects only.
- Service type LoadBalancer: EXTERNAL-IP stays `<pending>` without MetalLB or cloud-provider-kind; q92 and q93 grade spec and nodePort only.
- Ingress controller / IngressClass: ingress-nginx is retired and absent by default. q34 and q100 are optional; q101 and q102 grade the spec and default-class admission only.
- VPA: needs the VPA CRDs and components; q61 and q62 are low fidelity (the stand-in VPA CRD).
- HA control plane: kind is a single control plane; q21 and q81 are read-only or design-only facts.
- kube-proxy: iptables mode is inspectable (q96, which needs ssh to k8s-worker), but traffic-path debugging inside kind node containers is only partly representative.
- Node-level fixes (kubelet, etcd, control-plane manifests) need systemd and root inside the node; they run on the ek8s/k8s labs with ssh aliases (q37-q41, q18, q76, q79, q80).
- metrics-server: needs --kubelet-insecure-tls on kind; q105 is medium fidelity (self-signed kubelet certs).
- RuntimeClass with a non-runc handler (gVisor, kata): only runc exists, so q26 and q91 use the default handler.
