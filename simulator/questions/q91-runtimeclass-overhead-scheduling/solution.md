# q91 풀이

```bash
kubectl config use-context k8s
# 1) containerd 핸들러 확인 (읽기 전용)
ssh k8s-node1 "sudo grep -E 'containerd.runtimes\.[a-z]+\]' /etc/containerd/config.toml"
#   [plugins.'io.containerd.grpc.v1.cri'.containerd.runtimes.runc]  -> 핸들러 이름: runc
echo runc > ~/answers/q91-handlers.txt

# 2) RuntimeClass
cat <<'EOF' | kubectl apply -f -
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: sandboxed
handler: runc
overhead:
  podFixed:
    cpu: 100m
    memory: 32Mi
scheduling:
  nodeSelector:
    runtime: sandbox
EOF

# 3) Deployment
kubectl -n rc-lab create deployment sbx --image=busybox:1.37 --replicas=2 -- sleep 3600
kubectl -n rc-lab patch deployment sbx --type=merge -p '{"spec":{"template":{"spec":{"runtimeClassName":"sandboxed"}}}}'
kubectl -n rc-lab get pods -o wide                       # 모두 k8s-worker
kubectl -n rc-lab get pod -l app=sbx -o jsonpath='{.items[0].spec.overhead}'
```

핵심: RuntimeClass의 `scheduling.nodeSelector`는 해당 클래스를 쓰는 Pod의 nodeSelector에 병합되어 Pod가 올바른 노드로 간다. `overhead.podFixed`는 admission 시 Pod `spec.overhead`로 복사되어 스케줄링과 쿼터 계산에 더해진다. handler 이름은 containerd 설정의 `runtimes.<이름>`과 정확히 같아야 한다. 이 랩에는 runc만 있으므로 기능은 기본 런타임과 같다 (fidelity: partial).

문서: https://kubernetes.io/docs/concepts/containers/cri/
