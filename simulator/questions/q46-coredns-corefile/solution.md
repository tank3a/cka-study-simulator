# q46 - 해설 (CoreDNS Corefile 오류)

## 진단 순서
```bash
kubectl -n dns-fix exec deploy/client -- nslookup web.dns-fix.svc.cluster.local     # NXDOMAIN / can't find
kubectl -n dns-fix exec deploy/client -- cat /etc/resolv.conf                        # nameserver = kube-dns ClusterIP, search ... cluster.local
kubectl -n kube-system get pods -l k8s-app=kube-dns -o wide                          # Running 이지만 설정이 틀릴 수 있음
kubectl -n kube-system logs -l k8s-app=kube-dns --tail=30
kubectl -n kube-system get svc kube-dns ; kubectl -n kube-system get endpoints kube-dns
kubectl -n kube-system get cm coredns -o yaml                                        # Corefile 확인
```
Corefile 에서 두 곳이 틀림:
- `kubernetes cluster.lcl in-addr.arpa ip6.arpa` -> `cluster.local` (클러스터 도메인 오타. 이 때문에 svc.cluster.local 질의가 NXDOMAIN)
- `forward . 10.255.255.1` -> `forward . /etc/resolv.conf` (외부 질의 timeout)

## 수정
```bash
kubectl -n kube-system edit cm coredns
kubectl -n kube-system rollout restart deploy/coredns     # reload 플러그인이 있어도 확실히 적용하려면
kubectl -n kube-system rollout status deploy/coredns
```

## 검증 및 산출물
```bash
mkdir -p /home/candidate/q46
kubectl -n dns-fix exec deploy/client -- nslookup web.dns-fix.svc.cluster.local | tee /home/candidate/q46/nslookup.txt
kubectl -n dns-fix exec deploy/client -- wget -qO- -T3 http://web.dns-fix.svc.cluster.local
```

## 포인트
- DNS 문제 3단계: pod 의 `/etc/resolv.conf` -> kube-dns Service/Endpoints -> CoreDNS 로그/ConfigMap.
- CoreDNS pod 가 Running 이라고 설정이 맞는 것은 아니다.
- 파일 저장(`tee`, `>`)은 exec 바깥, 작업 터미널에서 실행한다.

문서: https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/ , https://kubernetes.io/docs/tasks/administer-cluster/coredns/ , https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
