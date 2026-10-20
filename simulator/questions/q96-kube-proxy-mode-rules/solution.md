# q96 풀이 (kube-proxy 모드와 Service 규칙 확인)

문서: https://kubernetes.io/docs/concepts/services-networking/service/

```bash
kubectl config use-context k8s
kubectl -n kube-system get ds kube-proxy
kubectl -n kube-system get cm kube-proxy -o jsonpath='{.data.config\.conf}' | grep -E '^\s*(mode|clusterCIDR):'
#   mode: iptables       (비어 있으면 기본값 iptables)
#   clusterCIDR: 10.244.0.0/16

ssh k8s-node1
sudo iptables-save -t nat | grep 'kp-lab/echo:http cluster IP'
#   -A KUBE-SERVICES -d 10.96.x.y/32 -p tcp -m comment --comment "kp-lab/echo:http cluster IP" -m tcp --dport 80 -j KUBE-SVC-XXXXXXXXXXXXXXXX
exit
```

결과 파일 예:

```
mode=iptables
cluster-cidr=10.244.0.0/16
chain=KUBE-SVC-XXXXXXXXXXXXXXXX
```

- kube-proxy 설정은 DaemonSet 이 마운트하는 ConfigMap `kube-proxy`(`config.conf`)에 있다. 수정하려면 ConfigMap 편집 후 DaemonSet rollout restart 가 필요하다 (이 문제에서는 읽기만).
- iptables 모드에서 `KUBE-SERVICES` -> `KUBE-SVC-*`(Service 당 하나) -> `KUBE-SEP-*`(endpoint 당 하나) 순서로 DNAT 된다. `iptables-save` 의 comment 에 `<ns>/<svc>:<port-name>` 이 들어 있어 검색이 쉽다.
- 체인 이름은 해시라서 노드가 달라도 같다.
