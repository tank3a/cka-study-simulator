# q94 풀이 (Headless Service + Pod DNS)

문서: https://kubernetes.io/docs/concepts/services-networking/service/

```bash
kubectl config use-context k8s
kubectl -n hl-dns apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata: {name: db-hl}
spec:
  clusterIP: None          # headless
  selector: {app: db}
  ports: [{port: 80, targetPort: 80}]
YAML

kubectl -n hl-dns exec tester -- nslookup db-hl.hl-dns.svc.cluster.local     # Pod IP 3개 (A record 3개)
kubectl -n hl-dns exec tester -- nslookup db-hl.hl-dns.svc.cluster.local | grep -Ec '^Address:[[:space:]]+[0-9.]+$' > /home/candidate/hl-count.txt
echo db-1.db-hl.hl-dns.svc.cluster.local > /home/candidate/hl-pod.txt
```

- headless Service(`clusterIP: None`)는 ClusterIP 하나가 아니라 Ready 상태인 Pod IP 전체를 A 레코드로 돌려준다.
- StatefulSet Pod 는 `<pod>.<service>.<ns>.svc.<cluster-domain>` 형태의 고정 이름을 얻으며, 이는 StatefulSet 의 `serviceName` 과 같은 이름의 headless Service 가 있을 때만 생긴다.
- `nslookup` 출력 첫 `Address:` 줄(`10.96.0.10:53`, 포트 포함)은 DNS 서버이므로 세지 않는다. 위 정규식은 IP 만 있는 응답 줄만 센다. 결과가 이상하면 출력을 직접 눈으로 세자.
