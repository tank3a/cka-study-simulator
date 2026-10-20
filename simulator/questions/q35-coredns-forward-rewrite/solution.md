# q35 풀이 (CoreDNS Corefile: 존 forward + rewrite)

문서: https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/
(CoreDNS 개요: https://kubernetes.io/docs/tasks/administer-cluster/coredns/ , 확인: https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)

```bash
kubectl config use-context k8s
kubectl -n dns-lab get svc corp-dns -o jsonpath='{.spec.clusterIP}'      # 예: 10.96.x.y
kubectl -n kube-system edit cm coredns
```

기존 `.:53 { ... }` 블록 **안**의 `kubernetes` 플러그인 앞에 rewrite 를 넣고, 같은 ConfigMap 에 새 server block 을 추가한다.

```
.:53 {
    errors
    health { lameduck 5s }
    ready
    rewrite name exact old-db.example.org db.dns-lab.svc.cluster.local
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf { max_concurrent 1000 }
    cache 30
    loop
    reload
    loadbalance
}
corp.internal:53 {
    errors
    cache 30
    forward . <corp-dns ClusterIP>
}
```

```bash
# reload 플러그인이 30~60초 안에 반영한다. 급하면:
kubectl -n kube-system rollout restart deploy/coredns
kubectl -n dns-lab exec dnsclient -- nslookup app.corp.internal          # 10.1.2.3
kubectl -n dns-lab exec dnsclient -- nslookup old-db.example.org          # db 서비스 ClusterIP
```

- `rewrite name exact ...` 는 기본 server block(`.:53`) 안에 둔다. 위치는 `kubernetes` 앞으로 두면 읽기 쉽다.
- 문법 오류가 나면 CoreDNS 가 CrashLoop/reload 실패 -> `kubectl -n kube-system logs deploy/coredns` 로 확인.
- 잘못된 forward 대상(ClusterIP 오타)이 흔한 실수.
