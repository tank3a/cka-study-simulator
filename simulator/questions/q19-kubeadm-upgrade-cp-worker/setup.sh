set -uo pipefail
source "$LIB/common.sh"
# Best effort preparation: check that the local apt repo offers 1.35 packages on both nodes.
for n in ik8s-cp ik8s-node1; do
  node_sh "$n" 'apt-mark unhold kubeadm kubelet kubectl >/dev/null 2>&1; apt-get update -qq >/dev/null 2>&1; apt-cache madison kubeadm | grep -q "1\.35\." || echo "WARN: no kubeadm 1.35 in apt repo" >&2' || true
done
kc ik8s uncordon ik8s-control-plane >/dev/null 2>&1 || true
kc ik8s uncordon ik8s-worker >/dev/null 2>&1 || true
# kind/ik8s has no CNI, so nodes are NotReady and `kubeadm upgrade plan/apply` health checks fail. A real exam cluster has a CNI: install Calico
# from the offline manifest (idempotent, best effort) so the upgrade preflight passes.
if ! kc ik8s -n kube-system get ds calico-node >/dev/null 2>&1; then
  docker exec exam-term curl -fsS http://exam-assets/manifests/calico.yaml 2>/dev/null | sed 's|# - name: CALICO_IPV4POOL_CIDR|- name: CALICO_IPV4POOL_CIDR|; s|#   value: "192.168.0.0/16"|  value: "10.244.0.0/16"|' | kapply ik8s -f - >/dev/null 2>&1 \
    || log "WARN: could not install the offline CNI; kubeadm upgrade preflight may need --ignore-preflight-errors"
  wait_for 240 -- bash -c '! kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context ik8s get nodes --no-headers | grep -qv " Ready"' || log "WARN: ik8s nodes not Ready yet"
fi
