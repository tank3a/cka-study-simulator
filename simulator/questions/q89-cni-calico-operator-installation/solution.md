# q89 풀이

```bash
kubectl config use-context ik8s
cd ~/manifests
# 1) CRD가 커서 client-side apply의 annotation 한도를 넘는다 -> create (또는 apply --server-side)
kubectl create -f tigera-operator.yaml
kubectl -n tigera-operator rollout status deploy/tigera-operator

# 2) Installation의 CIDR을 클러스터 podSubnet으로
kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep podSubnet   # 예: 10.244.0.0/16
sed -i 's#cidr: 192.168.0.0/16#cidr: 10.244.0.0/16#' custom-resources.yaml
grep -n cidr custom-resources.yaml
kubectl create -f custom-resources.yaml     # Calico v3.33: the operator registers Goldmane/Whisker/etc. CRDs after it starts; if you get 'no matches for kind', wait ~20s and re-run (already-created objects report AlreadyExists)

# 3) 대기
kubectl get tigerastatus -w           # apiserver, calico 가 AVAILABLE=True
kubectl get nodes -w

# 4) 확인
kubectl -n cni-b get pods -o wide
IP=$(kubectl -n cni-b get pod -l app=net-probe -o jsonpath='{.items[1].status.podIP}')
kubectl -n cni-b exec deploy/net-probe -c cli -- wget -qO- -T3 http://$IP | head -3
```

함정: `kubectl apply -f tigera-operator.yaml`은 "metadata.annotations: Too long" 오류가 날 수 있다 (`create` 또는 `apply --server-side`). Installation CR의 cidr은 `kubeadm init`의 podSubnet과 일치해야 한다. 이 문제는 ik8s가 필요하며 q88과 함께 한 세트에 넣지 않는다 (둘 다 CNI를 설치). 종료 후 cluster-hard reset.

문서: https://kubernetes.io/docs/concepts/cluster-administration/addons/
      https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/
