# q60 해설: TLS / docker-registry / generic Secret, defaultMode, secretKeyRef

문서:
- https://kubernetes.io/docs/concepts/configuration/secret/ (`Ctrl+F` `kubernetes.io/tls`, `dockerconfigjson`, `defaultMode`)
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/ (volume/env 사용 패턴 비교)

## 풀이
```bash
kubectl config use-context k8s
kubectl -n secret-demo create secret tls web-tls --cert=/home/candidate/certs/tls.crt --key=/home/candidate/certs/tls.key
kubectl -n secret-demo create secret docker-registry regcred \
  --docker-server=registry.example.com --docker-username=ci-bot --docker-password='Pa55w0rd!' --docker-email=ci@example.com
kubectl -n secret-demo patch sa app-sa -p '{"imagePullSecrets":[{"name":"regcred"}]}'
kubectl -n secret-demo create secret generic api-token --from-literal=token=abc123
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata: {name: secure-app, namespace: secret-demo}
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: nginx:1.27
    env:
    - name: API_TOKEN
      valueFrom:
        secretKeyRef: {name: api-token, key: token}
    volumeMounts:
    - {name: tls, mountPath: /etc/tls, readOnly: true}
  volumes:
  - name: tls
    secret:
      secretName: web-tls
      defaultMode: 0440
EOF
```
YAML 의 `defaultMode: 0440` 은 8진수 표기 (API 에는 288 로 저장). JSON 으로 쓰면 288.

## 검증
```bash
kubectl -n secret-demo exec secure-app -- sh -c 'ls -l /etc/tls; echo $API_TOKEN'
kubectl -n secret-demo get sa app-sa -o yaml
```
(파일 모드 0440 은 심볼릭 링크 대상 파일 기준으로 `-r--r-----`.)

## 흔한 실수
- `create secret generic` 으로 tls Secret 을 만들어 type 이 Opaque (Ingress/서버에서 거부).
- `defaultMode: 440` (10진수) 로 써서 의도와 다른 모드.
- imagePullSecrets 를 Pod 가 아닌 곳에 오타로 넣었거나 SA 를 지정하지 않음.
- 비밀번호의 `!` 가 쉘에서 해석됨 (작은따옴표 사용).
