# q36 풀이 (DNS 디버깅 + Pod CIDR / CNI / CoreDNS Service)

문서: https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
(Pod DNS 정책: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/ , 네트워킹 개념: https://kubernetes.io/docs/concepts/cluster-administration/networking/)

## Part 1
```bash
kubectl config use-context k8s
kubectl -n net-debug exec broken-client -- cat /etc/resolv.conf     # nameserver 192.0.2.53 (잘못됨)
kubectl -n net-debug exec healthy-client -- cat /etc/resolv.conf    # 비교: nameserver <kube-dns ClusterIP>
kubectl -n net-debug get pod broken-client -o yaml | grep -A8 dnsPolicy
# dnsPolicy/dnsConfig 는 수정 불가 -> 삭제 후 재생성
kubectl -n net-debug get pod broken-client -o yaml > bc.yaml
vim bc.yaml    # dnsPolicy, dnsConfig 삭제 (status, nodeName, uid, resourceVersion 등 서버 필드도 정리). 기본값 ClusterFirst
kubectl -n net-debug delete pod broken-client --force --grace-period=0
kubectl apply -f bc.yaml
# 더 빠른 방법: kubectl -n net-debug run broken-client --image=busybox:1.37 --command -- sleep 86400
kubectl -n net-debug exec broken-client -- wget -qO- -T3 http://backend
```

## Part 2
```bash
kubectl get node k8s-worker -o jsonpath='{.spec.podCIDR}' > /home/candidate/podcidr-node1.txt
ssh k8s-node1 sudo ls /etc/cni/net.d      # kindnet 의 경우 10-kindnet.conflist
echo 10-kindnet.conflist > /home/candidate/cni-conf.txt     # ls 로 확인한 실제 이름을 쓸 것
kubectl -n kube-system get svc kube-dns -o jsonpath='{.spec.clusterIP}' > /home/candidate/dns-ip.txt
```

- CoreDNS Service 이름은 호환성 때문에 `kube-dns` 이다.
- 이 kind 클러스터의 CNI 는 kindnet 이므로 파일 이름이 실제 시험(Calico/Cilium 등)과 다를 수 있다. 개념(`/etc/cni/net.d`, 노드별 podCIDR)은 같다.
