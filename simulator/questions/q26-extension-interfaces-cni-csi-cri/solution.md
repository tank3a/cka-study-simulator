# q26 풀이

```bash
kubectl config use-context k8s
# CRI socket: 이 kind 노드에는 kubeadm cri-socket annotation이 없다 -> 노드의 kubelet/crictl 설정에서 읽는다 (아래 ssh 단계)
# (일반 kubeadm 클러스터: kubectl get node <n> -o jsonpath='{.metadata.annotations.kubeadm\.alpha\.kubernetes\.io/cri-socket}')
kubectl get node k8s-worker -o jsonpath='{.spec.podCIDR}'
kubectl get sc                                   # (default) 표시
kubectl get sc standard -o jsonpath='{.provisioner}'   # CSI/external provisioner 이름

ssh k8s-node1; sudo -i
crictl version                                   # RuntimeName: containerd
ls /etc/cni/net.d                                # CNI 설정 파일 (kind: 10-kindnet.conflist)
ls /opt/cni/bin                                  # CNI 플러그인 바이너리 기본 위치
grep containerRuntimeEndpoint /var/lib/kubelet/config.yaml   # unix:///run/containerd/containerd.sock
cat /etc/crictl.yaml                             # runtime-endpoint 도 동일
exit; exit

cat > ~/answers/q26.txt <<'TXT'
cri_socket=unix:///run/containerd/containerd.sock
runtime_name=containerd
cni_config_file=10-kindnet.conflist
cni_bin_dir=/opt/cni/bin
pod_cidr=<노드의 podCIDR>
default_storageclass=standard
csi_provisioner=rancher.io/local-path
TXT

kubectl apply -f - <<'YAML'
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: standard-runc
handler: runc
YAML
kubectl -n ext-if run rc-pod --image=busybox:1.37 --dry-run=client -o yaml --overrides='{"spec":{"runtimeClassName":"standard-runc"}}' -- sleep 3600 | kubectl apply -f -
```

핵심: Kubernetes는 kubelet-CRI(런타임), CNI(네트워크 플러그인), CSI(스토리지 드라이버)라는 표준 인터페이스로 구현체를 교체한다. RuntimeClass의 `handler`는 CRI 런타임(containerd)에 설정된 핸들러 이름과 일치해야 한다. kind 값은 환경 의존적이므로 실제 클러스터에서 읽어서 쓸 것(위 값은 예시).

문서: https://kubernetes.io/docs/concepts/containers/cri/
      https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/
      https://kubernetes.io/docs/concepts/storage/volumes/#csi
