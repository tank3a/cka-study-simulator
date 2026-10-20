# q10 해설: 네이티브 사이드카 (initContainers + restartPolicy: Always)

문서: https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/ (`Ctrl+F` `restartPolicy: Always`)
(Kubernetes 1.29+ 에서 beta/기본 활성, 1.33 GA.) 
핵심: 사이드카는 `containers` 가 아니라 **`initContainers`** 에 넣고 `restartPolicy: Always` 를 붙인다.
- 일반 `containers` 에 추가해도 동작은 하지만 "native sidecar" 요구사항에는 맞지 않는다 (시작 순서/종료 순서 보장 없음).
- `restartPolicy: Always` 가 없으면 init container 로 취급되어 `tail -F` 가 끝나지 않아 Pod 가 영원히 Init 상태에 머문다.

## 풀이
```bash
kubectl config use-context k8s
kubectl -n sidecar-demo edit deploy shipper     # 또는 get -o yaml > d.yaml 후 vim
```
`spec.template.spec` 아래 (containers 와 같은 레벨) 에 추가:
```yaml
      initContainers:
      - name: log-agent
        image: busybox:1.37
        command: ["tail", "-F", "/var/log/app/app.log"]
        restartPolicy: Always
        resources:
          limits:
            cpu: 50m
            memory: 32Mi
        volumeMounts:
        - name: logs
          mountPath: /var/log/app
          readOnly: true
        - name: agent-config
          mountPath: /etc/agent
      containers:
      - name: app
        ...
      volumes:
      - name: logs
        emptyDir: {}
      - name: agent-config
        configMap:
          name: agent-config
```
- `volumes` 에는 기존 `logs` 를 유지하고 `agent-config` (configMap) 를 **추가** 한다.
- 시험에서 자주 나오는 변형(S8 경고): 이미 `initContainers` 가 있는 Deployment 에서는 기존 항목을 지우지 말고 리스트에 이어 붙인다.

## 검증
```bash
kubectl -n sidecar-demo rollout status deploy/shipper
kubectl -n sidecar-demo get pods              # READY 2/2
kubectl -n sidecar-demo logs deploy/shipper -c log-agent --tail=3
kubectl -n sidecar-demo exec deploy/shipper -c log-agent -- cat /etc/agent/agent.conf
```
(리소스 limit 이 32Mi 라 OOMKilled 되면 `kubectl describe pod` 로 확인.)

## 흔한 실수
- `restartPolicy: Always` 를 container 의 `command` 와 같은 레벨이 아니라 `spec` 에 둠.
- `volumes` 를 새로 정의하면서 기존 `logs` 를 지움.
- `readOnly: true` 는 volumeMount 쪽에 쓴다.
