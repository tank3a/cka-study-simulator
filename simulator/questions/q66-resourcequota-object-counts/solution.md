# q66 해설: 오브젝트 개수 / 스토리지 ResourceQuota 와 거부 확인

문서:
- https://kubernetes.io/docs/concepts/policy/resource-quotas/ (`Ctrl+F` `Object Count Quota`, `count/`)

## 핵심
- quota 키: `count/deployments.apps`, `persistentvolumeclaims`, `requests.storage`, `services.nodeports`.
- quota 는 생성 시점 admission 에서 검사된다. 이미 있는 `existing` Deployment 와 `pvc-a` 는 quota 사용량으로 집계된다 (Deployments 1/2, PVC 1/2, storage 1Gi/3Gi).
- 결과: `a-deploy-extra` 허용(2/2), `b-deploy-third` 거부, NodePort 거부(0), `pvc-big` 5Gi 거부, `pvc-small` 허용(PVC 2/2, 2Gi).

## 풀이
```bash
kubectl config use-context k8s
kubectl -n quota-b create quota object-caps --hard=count/deployments.apps=2,persistentvolumeclaims=2,requests.storage=3Gi,services.nodeports=0
kubectl -n quota-b apply -f /home/candidate/quota-tests/ 2> /home/candidate/quota-errors.txt
cat /home/candidate/quota-errors.txt
```
`kubectl apply -f <dir>` 은 일부가 실패해도 나머지를 계속 적용한다.

## 검증
```bash
kubectl -n quota-b describe quota object-caps
kubectl -n quota-b get deploy,svc,pvc
```

## 흔한 실수
- 디렉터리 대신 파일 하나씩 적용하다 일부를 빠뜨림.
- 리다이렉트를 `>` 로 해서 stderr 가 파일에 남지 않음 (`2>`).
- `services.nodeports=0` 은 NodePort 와 LoadBalancer 타입 모두에 영향 (LoadBalancer 도 nodePort 를 할당).
- quota 를 만들기 전에 테스트 manifest 를 적용 (그러면 모두 통과해 버린다).
