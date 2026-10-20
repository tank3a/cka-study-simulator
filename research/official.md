# CKA official exam facts (researched 2026-10-18)

Source legend: [CUR] https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.37.pdf (read via https://raw.githubusercontent.com/cncf/curriculum/master/CKA_Curriculum_v1.37.pdf); [LF] https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/ ; [TIPS] https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad ; [FAQ] https://docs.linuxfoundation.org/tc-docs/certification/faq-cka-ckad-cks ; [RES] https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed ; [RULES] https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-rules-and-policies ; [UI] https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-user-interface/examui-performance-based-exams ; [TOS] https://docs.linuxfoundation.org/tc-docs/certification/exam-terms-of-service

## 1. Curriculum
- Version: CKA_Curriculum_v1.37.pdf is the only current CKA file in the repo root (https://github.com/cncf/curriculum). README states major.minor matches the Kubernetes version (https://github.com/cncf/curriculum/blob/master/README.md).
- Exam runs Kubernetes v1.37 (CKA and CKAD; CKS is v1.35): [FAQ], [TIPS], [LF].
- Weights (identical in [CUR], [LF], and https://github.com/cncf/curriculum/blob/master/cka/README.md): Cluster Architecture, Installation & Configuration 25%; Workloads & Scheduling 15%; Services & Networking 20% (the PDF misspells it "Servicing and Networking"); Storage 10%; Troubleshooting 30%.

### Sub-competencies (verbatim from [CUR])
**Storage 10%**: Implement storage classes and dynamic volume provisioning; Configure volume types, access modes and reclaim policies; Manage persistent volumes and persistent volume claims.
**Troubleshooting 30%**: Troubleshoot clusters and nodes; Troubleshoot cluster components; Monitor cluster and application resource usage; Manage and evaluate container output streams; Troubleshoot services and networking.
**Workloads & Scheduling 15%**: Understand application deployments and how to perform rolling update and rollbacks; Use ConfigMaps and Secrets to configure applications; Configure workload autoscaling; Understand the primitives used to create robust, self-healing, application deployments; Configure Pod admission and scheduling (limits, node affinity, etc.).
**Cluster Architecture, Installation & Configuration 25%**: Manage role based access control (RBAC); Prepare underlying infrastructure for installing a Kubernetes cluster; Create and manage Kubernetes clusters using kubeadm; Manage the lifecycle of Kubernetes clusters; Implement and configure a highly-available control plane; Use Helm and Kustomize to install cluster components; Understand extension interfaces (CNI, CSI, CRI, etc.); Understand CRDs, install and configure operators.
**Services & Networking 20%**: Understand connectivity between Pods; Define and enforce Network Policies; Use ClusterIP, NodePort, LoadBalancer service types and endpoints; Use the Gateway API to manage Ingress traffic; Know how to use Ingress controllers and Ingress resources; Understand and use CoreDNS.

### What changed
- I diffed the PDFs: v1.35 (https://github.com/cncf/curriculum/blob/master/old-versions/CKA_Curriculum_v1.35.pdf) has bullet-for-bullet identical content to v1.37. So no change between 1.35 and 1.37 (I did not diff v1.36; its file is not in the listing at https://api.github.com/repos/cncf/curriculum/contents/old-versions, nor in root).
- Versus the old v1.24 curriculum (https://github.com/cncf/curriculum/blob/master/old-versions/CKA_Curriculum_v1.24.pdf), the new bullets are: workload autoscaling; Helm and Kustomize (replacing "awareness of manifest management and templating tools"); extension interfaces CNI/CSI/CRI; CRDs and operators; Gateway API; "Monitor cluster and application resource usage". Removed as explicit bullets: etcd backup/restore and kubeadm version upgrade (now implied by "Manage the lifecycle of Kubernetes clusters"; still covered by the doc pages below, but the explicit wording is gone); host networking config; choosing a CNI plugin. The pre-2025 file "CKA_Curriculum Coming Soon Q1 2025.pdf" indicates the rewrite landed in 2025 (exact effective date UNVERIFIED).

## 2. Exam format
- Duration 2 hours: [LF], [TIPS], [FAQ]. Online, proctored, performance-based (command line): [LF].
- Number of tasks: "15-20" performance-based tasks: [TIPS]. [FAQ] gives no count.
- Passing score: 66% or above for CKA: [FAQ]. (Not stated on [LF].)
- Retake: one free retake per exam purchase, must be taken within 12 months of original purchase (or before corporate subscription expiry); no waiting period specified: [TOS] Retake policy; "One Retake" in [LF]. Rescoring request within 2 days of score report, for a fee, refunded if it flips to pass: https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-scoring-and-notification/exam-results-no-pass
- Validity 2 years (3 years if earned before 2024-04-01); results emailed within 24 hours; CARE: earning/recertifying CKS on or after 2026-06-18 extends CKA expiry to match CKS: [FAQ].
- Proctoring: PSI Bridge with the PSI Secure Browser (Chrome-based, downloaded at launch); one monitor only; webcam + mic; 1080p/15"+ recommended; HTTPS to AWS S3 endpoints must be allowed; no VMs; close other apps; personal device preferred; run PSI system check beforehand: [TIPS], [FAQ]. Valid unexpired government photo ID with signature, name must match: [TIPS].
- Room/conduct: quiet private well-lit room, clear desk, nobody else present; no leaving camera view without proctor permission; no phones/smartwatches/wearables; no eating or gum, clear liquids only in a label-free clear bottle/glass; no notes; sessions recorded, zero tolerance: [RULES].
- Environment: remote desktop VM with terminal emulator, Firefox (for allowed docs), virtual keyboard; VSCodium available (extensions prohibited); "Reset Desktop" if it fails to load; timer alerts at 30/15/5 min; pausing does not stop the timer; ReadMe tab + Remote Desktop tab: [UI]. Firefox has Ctrl+F and the Simple Translate extension: [UI].
- Each task names a host; use `ssh <nodename>`, `exit` to return to `base`; nested ssh unsupported; `sudo -i` for root; kubectl (alias `k`, bash completion), yq, curl, wget, man exist on the ssh hosts but NOT on base; do not reboot base: [TIPS].
- Number of clusters/contexts: UNVERIFIED. The official pages above do not describe kubectl contexts. The ssh-per-task host model suggests each task specifies its own host/cluster in its infobox; read it every time.
- Keys: Ctrl+Alt+W instead of Ctrl+W; terminal copy/paste Ctrl+Shift+C / Ctrl+Shift+V; Insert key disabled; Ctrl+Alt+K finds cursor: [TIPS].
- Exam-time notepad/flag features: UNVERIFIED ([UI] does not cover them).

## 3. Allowed resources (from [RES], CKA section)
- https://kubernetes.io/docs
- https://kubernetes.io/blog/
- https://helm.sh/docs
- https://gateway-api.sigs.k8s.io (CKA only)
- Task-specific docs linked in the Quick Reference box of a task.
- Translated Kubernetes docs (e.g. kubernetes.io/zh/docs) allowed; English recommended.
- Search: the search function on kubernetes.io/docs may be used; you "must not open external search results."
- Other: exam instructions in the terminal; docs under /usr/share (man pages); distribution packages may be installed.
- Resources must be accessed from within the exam Linux terminal/VM browser, used independently, not for third-party help.
- Note: kubernetes.io/docs/... links from the allowed site's own pages (e.g. GitHub, external links) are not allowed. (inferred; UNVERIFIED as stated rule)

## 4. Doc URLs per sub-competency
All URLs below returned HTTP 200 (curl -L) on 2026-10-18 unless noted. Items marked (R) redirect to the canonical URL shown.

### Storage (10%)
- Storage classes and dynamic provisioning: https://kubernetes.io/docs/concepts/storage/storage-classes/ ; https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/
- Volume types, access modes, reclaim policies: https://kubernetes.io/docs/concepts/storage/volumes/ ; https://kubernetes.io/docs/concepts/storage/persistent-volumes/ (access modes and reclaim policy sections)
- PV and PVC: https://kubernetes.io/docs/concepts/storage/persistent-volumes/ ; https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage (404 now, do not rely on; use the concepts page)

### Troubleshooting (30%)
- Clusters and nodes: https://kubernetes.io/docs/tasks/debug/debug-cluster/ ; https://kubernetes.io/docs/concepts/architecture/nodes/ ; https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
- Cluster components: https://kubernetes.io/docs/tasks/debug/debug-cluster/ ; https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ ; https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ (kubeadm troubleshooting; pages under it verified individually below)
- Monitor resource usage: https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/ ; https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/
- Container output streams: https://kubernetes.io/docs/concepts/cluster-administration/logging/ ; https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/ ; https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/
- Services and networking: https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/ ; https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/

### Workloads & Scheduling (15%)
- Deployments, rolling update, rollback: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ ; https://kubernetes.io/docs/reference/kubectl/generated/kubectl_rollout/
- ConfigMaps and Secrets: https://kubernetes.io/docs/concepts/configuration/configmap/ ; https://kubernetes.io/docs/concepts/configuration/secret/ ; https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
- Workload autoscaling: https://kubernetes.io/docs/concepts/workloads/autoscaling/ ; https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/ (R from /docs/tasks/run-application/horizontal-pod-autoscale/) ; https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/ ; VPA: https://kubernetes.io/docs/concepts/workloads/autoscaling/vertical-pod-autoscale/
- Self-healing primitives: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/ ; https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ ; https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/
- Pod admission and scheduling (limits, affinity): https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ ; https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ ; https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ ; https://kubernetes.io/docs/concepts/policy/limit-range/ ; https://kubernetes.io/docs/concepts/policy/resource-quotas/ ; https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/

### Cluster Architecture, Installation & Configuration (25%)
- RBAC: https://kubernetes.io/docs/reference/access-authn-authz/rbac/ ; https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/
- Prepare infrastructure: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/ ; https://kubernetes.io/docs/setup/production-environment/container-runtimes/
- Clusters with kubeadm: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
- Lifecycle (upgrade, certs, drain, etcd backup/restore): https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/ ; https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/ ; https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/ ; https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
- HA control plane: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/ ; https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/
- Helm and Kustomize: https://helm.sh/docs/intro/using_helm/ ; https://helm.sh/docs/intro/install/ ; https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
- Extension interfaces: CNI https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/ and https://kubernetes.io/docs/concepts/cluster-administration/addons/ ; CSI https://kubernetes.io/docs/concepts/storage/volumes/#csi ; CRI https://kubernetes.io/docs/concepts/containers/cri/ (R from /docs/concepts/architecture/cri/)
- CRDs and operators: https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/ ; https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/ ; https://kubernetes.io/docs/concepts/extend-kubernetes/operator/

### Services & Networking (20%)
- Pod connectivity: https://kubernetes.io/docs/concepts/cluster-administration/networking/ ; https://kubernetes.io/docs/concepts/services-networking/
- Network Policies: https://kubernetes.io/docs/concepts/services-networking/network-policies/ ; https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/
- Services and endpoints: https://kubernetes.io/docs/concepts/services-networking/service/ ; https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/ ; https://kubernetes.io/docs/tutorials/services/connect-applications-service/
- Gateway API: https://kubernetes.io/docs/concepts/services-networking/gateway/ ; https://gateway-api.sigs.k8s.io/ ; https://gateway-api.sigs.k8s.io/guides/getting-started/introduction/ (R from /guides/) ; https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/ (R from /guides/http-routing/). Note https://gateway-api.sigs.k8s.io/api-types/httproute/ returns 404.
- Ingress: https://kubernetes.io/docs/concepts/services-networking/ingress/ ; https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/
- CoreDNS: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/ ; https://kubernetes.io/docs/tasks/administer-cluster/coredns/ ; https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/

### General
- kubectl cheat sheet: https://kubernetes.io/docs/reference/kubectl/quick-reference/

## 5. Caveats
- kubernetes.io/docs on the live site is the latest release docs; the exam VM Firefox presumably opens the same site (UNVERIFIED whether any version pinning applies).
- I verified page fetch status, not the full page text of every URL; mapping to sub-competencies is my judgement.
