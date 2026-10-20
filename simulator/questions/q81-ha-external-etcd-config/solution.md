# q81 풀이

```bash
kubectl config use-context ek8s
# 리더 lease: holderIdentity는 "<노드이름>_<uuid>" 형식
kubectl -n kube-system get lease kube-controller-manager -o jsonpath='{.spec.holderIdentity}'
#  -> ek8s-control-plane_xxxxxxxx...  : 노드 이름만 기록

mkdir -p ~/answers
cat > ~/answers/q81.txt <<EOF
controller_manager_leader=ek8s-control-plane
quorum_5=3
tolerated_failures_5=2
min_members_survive_2=5
EOF
# quorum = floor(n/2)+1 : n=5 -> 3, 허용 장애 = n - quorum = 2, 2대를 잃어도 살아남는 최소 크기는 2*2+1 = 5

ssh ek8s-cp; sudo -i
cat > /opt/cka/ha-external-etcd.yaml <<'EOF'
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: v1.34.0
controlPlaneEndpoint: lb.ha.example.com:6443
etcd:
  external:
    endpoints:
    - https://10.0.0.11:2379
    - https://10.0.0.12:2379
    - https://10.0.0.13:2379
    caFile: /etc/kubernetes/pki/etcd/ca.crt
    certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
    keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
EOF
kubeadm config validate --config /opt/cka/ha-external-etcd.yaml
```

핵심: external etcd 토폴로지에서는 `etcd.external`에 엔드포인트와 클라이언트 인증서를 지정하고, kubeadm은 etcd static pod를 만들지 않는다. stacked 토폴로지는 `etcd.local`(기본값)을 쓴다. kind(단일 control plane)에서는 파일 작성과 검증만 가능하다.

문서: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
      https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/
