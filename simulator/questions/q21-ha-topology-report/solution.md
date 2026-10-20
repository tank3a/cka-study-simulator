# q21 풀이

```bash
kubectl config use-context ek8s
# topology: etcd가 kube-system의 static pod(노드 로컬)면 stacked, 별도 etcd endpoint(--etcd-servers가 외부)이면 external
kubectl -n kube-system get pods -o wide | grep etcd
kubectl -n kube-system get pod kube-apiserver-ek8s-control-plane -o yaml | grep etcd-servers

# 리더 선출 lease: holderIdentity = <node>_<uid>
kubectl -n kube-system get lease kube-scheduler -o jsonpath='{.spec.holderIdentity}'

# controlPlaneEndpoint
kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep controlPlaneEndpoint

# etcd 멤버 수 (노드에서)
ssh ek8s-cp; sudo -i
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list
```
min_cp_nodes_for_ha: etcd는 quorum(과반)이 필요하다. 1대 장애를 견디려면 3대(과반=2). 2대는 장애 허용 0.

예) 파일 내용:
```
topology=stacked
scheduler_leader=ek8s-control-plane
control_plane_endpoint=ek8s-control-plane:6443
etcd_members=1
min_cp_nodes_for_ha=3
```

문서: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/
      https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
