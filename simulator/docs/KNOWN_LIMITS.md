# Known limits (what is not faithful)

Verified on this machine (Docker Desktop, aarch64, kind v0.30.0, k8s v1.34.0): items marked VERIFIED. Everything else is untested or unfaithful.

* Terminal: runs in a container with tmux; no PSI browser, no docs restriction (honour system), no second monitor/web-docs tab. Internet egress of exam-term is blocked by iptables inside the container (VERIFIED). Candidate has no sudo there.
* `ssh <node>`: real sshd under systemd in a custom kind node image, key auth as `candidate` with passwordless sudo (VERIFIED). The real exam hosts are VMs; here they are containers sharing the Docker VM kernel. No `modprobe`, only namespaced sysctls, no swap handling, `reboot` is not meaningful (`docker restart` is the nearest thing).
* No Docker socket in exam-term (by design). `exam check/reset/end` from the terminal are relayed through a host daemon (`exam daemon`, started by `exam start`/`sim term`); if it is not running they time out. `exam solution` is host only.
* Grading runs on the Mac via `docker exec`/kubectl, not from the exam host; checks are my reading of what the real grader may test (rubric is not public).
* NetworkPolicy: kindnet enforces it (VERIFIED with deny-all test; `sim up` and `sim doctor` re-test). Calico fallback is not automated.
* Gateway API: NGINX Gateway Fabric 2.8.0 on arm64 works (VERIFIED, Gateway programmed, HTTPRoute served via NodePort from exam-term on all nodes). Data-plane Service is NodePort with externalTrafficPolicy Cluster; the port is random per Gateway. Real exams use whatever controller the task names; here a LoadBalancer IP never appears. Ingress-NGINX is only downloaded (`assets-cache/manifests/ingress-nginx-kind.yaml`), not installed or tested.
* metrics-server runs with `--kubelet-insecure-tls` (VERIFIED `kubectl top`). local-path StorageClass `standard` (VERIFIED present); it does not implement volume expansion.
* etcd: etcdctl/etcdutl 3.6.4 on nodes and in exam-term; snapshot save/status VERIFIED; baseline etcd restore by `sim restore-node --etcd` VERIFIED. A candidate-driven `etcdutl snapshot restore` + manifest edit was NOT run end to end.
* Node baseline restore (`sim restore-node`, used by cluster-soft resets) VERIFIED for a broken scheduler manifest; it restores /etc/kubernetes, kubelet config and drop-ins, and optionally etcd. It does not revert changes elsewhere (e.g. installed packages, files under /opt, containerd config beyond baseline). `exam reset` for questions without `host` restores every node of the cluster.
* `ik8s`: created with disableDefaultCNI; applying Calico manifest brought nodes Ready and calico-node Running (VERIFIED, calico-kube-controllers was still starting when torn down). Tigera-operator manifests are staged but untested. Kubeadm upgrade is NOT tested: v1.35 arm64 debs for kubeadm/kubelet/kubectl are in the offline apt repo (new nodes get the apt source; dependencies such as cri-tools/kubernetes-cni are not mirrored), kind's kubeadm config may fight `kubeadm upgrade apply`. Treat q19 as best effort.
* Alias contexts `mk8s`/`wk8s` are the same cluster with separate cluster-admin cert users, no default namespace.
* Offline-ness: first `sim up` needs internet (images, manifests, charts). Node image pulls need internet afterwards unless images are mirrored into `exam-assets:5000` by hand.
* `exam list/check` show only "checked" during a timed exam; real-exam scoring granularity is unknown.
* Not tested: full 16-task mock run, concurrent heavy load, Docker VM with < 6 GB, `exam reset --hard` (cluster recreate path), `sim down all`, Intel hosts.
* Idle memory measured: k8s control-plane ~1.1 GB, workers 0.2-0.3 GB, ek8s cp ~0.6 GB, term ~50 MB (about 3 GB for the default two clusters).
