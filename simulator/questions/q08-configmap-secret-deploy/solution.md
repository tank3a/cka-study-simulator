# q08 해설: ConfigMap / Secret 을 Deployment 에 주입

문서:
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/ (`Ctrl+F` `configMapKeyRef`, `--from-file`)
- https://kubernetes.io/docs/concepts/configuration/secret/ (`Ctrl+F` `secretKeyRef`, `defaultMode`)

## 1) ConfigMap / Secret 은 imperative 로
```bash
kubectl config use-context k8s
kubectl -n cfg-demo create configmap api-config \
  --from-literal=LOG_LEVEL=debug \
  --from-file=app.properties=/home/candidate/app.properties
kubectl -n cfg-demo create secret generic api-secret \
  --from-literal=username=admin --from-literal=password=S3cr3tPass
```
`--from-file=키=경로` 형태에서 키를 안 쓰면 키 이름이 파일명(`app.properties`)이 된다.

## 2) Deployment 수정
```bash
kubectl -n cfg-demo get deploy api -o yaml > api.yaml   # 또는 kubectl edit
vim api.yaml
```
컨테이너에 추가:
```yaml
      containers:
      - name: api
        image: busybox:1.37
        command: ["sleep","3600"]
        env:
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef: {name: api-config, key: LOG_LEVEL}
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef: {name: api-secret, key: password}
        volumeMounts:
        - {name: cfg, mountPath: /etc/api}
        - {name: sec, mountPath: /etc/secrets, readOnly: true}
      volumes:
      - name: cfg
        configMap: {name: api-config}
      - name: sec
        secret:
          secretName: api-secret
          defaultMode: 0400
```
- `defaultMode: 0400` 은 YAML 에서 8진수로 인식된다 (JSON 으로는 256). `0400` 대신 `256` 을 써도 같다.
- `kubectl edit deploy api` 로 수정하면 Pod 가 롤링 재시작된다.
- ConfigMap 전체를 env 로 넣고 싶으면 `envFrom: - configMapRef: {name: ...}` (이 문제는 키 단위 참조를 요구).

## 검증
```bash
kubectl -n cfg-demo rollout status deploy/api
kubectl -n cfg-demo exec deploy/api -- env | grep -E 'LOG_LEVEL|DB_PASSWORD'
kubectl -n cfg-demo exec deploy/api -- cat /etc/api/app.properties
kubectl -n cfg-demo exec deploy/api -- ls -l /etc/secrets
```

## 흔한 실수
- Secret 값을 base64 로 직접 넣을 때 `echo` 의 개행 포함 (`echo -n` 사용). `create secret generic` 을 쓰면 인코딩이 자동.
- `/etc/api` 에 mount 하면 디렉터리 전체가 가려진다 (필요 시 `subPath`).
- volumeMount 의 name 불일치, `secretName` 대신 `name` 을 쓰는 오타 (secret 볼륨은 `secretName`, configMap 볼륨은 `name`).
- env 만 바꾸고 Pod 재시작을 확인하지 않음 (ConfigMap 을 나중에 바꿔도 env 는 갱신되지 않음).
