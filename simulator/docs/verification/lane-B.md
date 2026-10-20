# Lane B verification (q25-q34, q36) - live run on k8s context

Driver: scratchpad B/d.sh (setup x2, grade untouched, solution via `docker exec -i -u candidate exam-term bash -l < script`, grade, cleanup, setup + grade, final cleanup). Scores are passed/total points. No `exam start/practice`, no node/kube-system changes.

| id | setup ok | idempotent | untouched | solution | reset ok | fixes made | status | note |
|---|---|---|---|---|---|---|---|---|
| q25-crd-inspect-create-cr | yes | yes | 0/8 | 8/8 | yes (0/8) | none | VERIFIED | |
| q26-extension-interfaces-cni-csi-cri | yes | yes | 0/10 | 10/10 | yes (0/10) | question.md + solution.md: node has no kubeadm cri-socket annotation (empty), so the cri_socket value is now read from kubelet config / crictl.yaml (/var/lib/kubelet/config.yaml containerRuntimeEndpoint) | VERIFIED | grader already fell back to unix:///run/containerd/containerd.sock |
| q27-svc-nodeport-expose | yes | yes | 1/11 | 11/11 | yes (1/11) | none | VERIFIED | untouched point = Deployment/Pods exist; nodePort 30080 is fixed, collides with any other lane using 30080 |
| q28-svc-selector-endpoints-debug | yes | yes | 2/9 | 9/9 | yes (2/9) | added cleanup.sh and setup rm of stale /home/candidate/api-endpoints.txt | VERIFIED | |
| q29-netpol-pick-least-permissive | yes | yes | 0/10 | 10/10 | yes (0/10) | none | VERIFIED | |
| q30-netpol-egress-dns | yes | yes | 3/8 | 8/8 | yes (3/8) | none | VERIFIED | untouched points are the baseline-works / no-ipBlock checks |
| q31-gateway-httproute-routing | yes | yes | 0/8 | 8/8 | yes (0/8) | setup now waits for the gateway data-plane Deployment web-gw-nginx | VERIFIED | |
| q32-gateway-tls-listener | yes | yes | 0/11 | 11/11 | yes (0/11) | grade.sh waits (90s) for deploy/shop-gw-nginx rollout when the Gateway exists (HTTP checks raced the freshly started data plane: 7/11 before) | VERIFIED | draft solution script used the IPv6 from getent in exam-term; nodes resolve to IPv6 first there, use `getent ahostsv4` |
| q33-ingress-to-gateway-migrate | yes | yes | 0/10 | 10/10 | yes (0/10) | setup now waits for deploy/main-gw-nginx (grading right after solution got 4/10 because the data plane was still starting) | VERIFIED | |
| q34-ingress-tls-paths | yes | yes | 0/6 | 6/6 | yes (0/6) | none | VERIFIED (spec only) | ingress-nginx not installed: live traffic checks skipped, grader is spec-only |
| q36-dns-pod-network-debug | yes | yes | 1/7 | 7/7 | yes (1/7) | question.md/solution.md: /etc/cni/net.d is root-only so `ssh` needs `sudo` (was permission denied); added cleanup.sh and setup rm of the three answer files (stale files made untouched/afterreset pass 2/7) | VERIFIED | |

Bug classes: (1) environment-dependent fact missing in this kind cluster (q26 cri-socket annotation), (2) task needs root but text omits sudo (q36), (3) stale candidate answer files not cleaned (q28, q36), (4) Gateway data-plane startup race in setup/grader (q31, q32, q33). Harness notes for solution scripts: `ssh` inside a script piped on stdin eats the rest of the script, use `ssh -n`.
All exam.q objects of these questions were removed at the end (namespaces, CRDs, RuntimeClass).
