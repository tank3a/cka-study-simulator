# q88 풀이

```bash
kubectl config use-context ik8s
kubectl get nodes                                  # NotReady (CNI 없음)
kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep podSubnet
#   podSubnet: 10.244.0.0/16
# (대안) kubectl get node ik8s-worker -o jsonpath='{.spec.podCIDR}'  -> 노드별 /24, 클러스터 전체 CIDR의 일부

cd ~/manifests
cp calico.yaml calico-custom.yaml
vim calico-custom.yaml
#   calico-node 컨테이너 env 에서 주석 처리된 항목을 풀고 값을 변경:
#   - name: CALICO_IPV4POOL_CIDR
#     value: "10.244.0.0/16"
kubectl apply -f calico-custom.yaml
kubectl -n kube-system rollout status ds/calico-node
kubectl get nodes -w                               # Ready 될 때까지

kubectl -n cni-a get pods -o wide
IP=$(kubectl -n cni-a get pod -l app=net-probe -o jsonpath='{.items[1].status.podIP}')
kubectl -n cni-a exec deploy/net-probe -c cli -- wget -qO- -T3 http://$IP | head -3
```

핵심: Calico의 IP 풀 CIDR이 `kubeadm init`의 `--pod-network-cidr`/`podSubnet`과 다르면 노드에 할당된 podCIDR과 어긋나 라우팅/IPAM 문제가 생긴다. 이 문제는 ik8s(기본 CNI 비활성)가 필요하고 끝나면 cluster-hard reset 한다. 실제 CKA에서는 CNI 매니페스트 URL/파일이 문제에 주어진다.

문서: https://kubernetes.io/docs/concepts/cluster-administration/addons/
      https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/
