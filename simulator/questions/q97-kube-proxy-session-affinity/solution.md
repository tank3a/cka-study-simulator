# q97 풀이 (Service sessionAffinity ClientIP)

문서: https://kubernetes.io/docs/concepts/services-networking/service/

```bash
kubectl config use-context k8s
kubectl -n kp-affinity patch svc sticky -p '{"spec":{"sessionAffinity":"ClientIP","sessionAffinityConfig":{"clientIP":{"timeoutSeconds":600}}}}'
# 또는 kubectl -n kp-affinity edit svc sticky

for i in $(seq 10); do kubectl -n kp-affinity exec tester -- wget -qO- -T3 http://sticky; done | sort -u
for i in $(seq 10); do kubectl -n kp-affinity exec tester -- wget -qO- -T3 http://sticky; done | sort -u | wc -l > /home/candidate/affinity.txt
```

- 기본값은 `sessionAffinity: None` 이라 요청마다 임의의 endpoint 로 분산된다.
- `ClientIP` 는 kube-proxy 가 클라이언트 IP 별로 endpoint 를 고정한다 (iptables 의 `recent` 모듈 / IPVS persistence). 기본 timeout 은 10800 s 이고 `timeoutSeconds` 로 바꾼다 (최대 86400).
- 확인: `sort -u` 결과가 한 줄이면 성공.
