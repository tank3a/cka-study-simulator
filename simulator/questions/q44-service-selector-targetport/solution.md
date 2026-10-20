# q44 - 해설 (selector / targetPort 불일치)

## 진단 순서
```bash
kubectl -n svc-lab get svc,endpoints            # ENDPOINTS 가 <none> 이면 selector 문제
kubectl -n svc-lab get svc shop-api -o yaml | grep -A2 selector
kubectl -n svc-lab get pods --show-labels
kubectl -n svc-lab describe svc shop-web         # Endpoints: IP:80 이 있는데 접속이 refused -> targetPort 문제
kubectl -n svc-lab exec deploy/tester -- wget -qO- -T3 http://shop-web
kubectl -n svc-lab get pod -l app=shop-web -o jsonpath='{.items[0].spec.containers[0].ports}'
```
- `shop-api`: selector `app=shop-apy` 와 pod label `app=shop-api` 불일치 -> Endpoints 비어 있음.
- `shop-web`: Endpoints 는 있으나 targetPort 80, 컨테이너는 8080 에서 listen -> `Connection refused`.

## 수정
```bash
kubectl -n svc-lab set selector svc/shop-api app=shop-api
kubectl -n svc-lab patch svc shop-web --type=json -p='[{"op":"replace","path":"/spec/ports/0/targetPort","value":8080}]'
```

## 검증
```bash
kubectl -n svc-lab get endpoints
kubectl -n svc-lab exec deploy/tester -- wget -qO- -T3 http://shop-api | head -3
kubectl -n svc-lab exec deploy/tester -- wget -qO- -T3 http://shop-web
```

## 포인트
- Endpoints 비어 있음 = selector/label 또는 readiness 문제, Endpoints 있는데 거부 = targetPort/앱 포트 문제.
- 순서: Service -> Endpoints -> Pod label -> Pod 포트 -> (그다음) DNS/NetworkPolicy.

문서: https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/ , https://kubernetes.io/docs/concepts/services-networking/service/
