# q41 - 해설 (static pod 경로 오류)

## 진단 순서
1. `kubectl -n static-demo get pods` -> 비어 있음.
2. `ssh k8s-node1` -> `sudo -i`
3. 파일 찾기: `find /etc/kubernetes -name 'audit-agent*'` -> `/etc/kubernetes/manifest/audit-agent.yaml` (끝에 `s` 없음).
4. kubelet 이 어디를 보는지: `grep staticPodPath /var/lib/kubelet/config.yaml` -> `/etc/kubernetes/manifests`
   (kubelet 설정 파일 경로가 다르면 `systemctl cat kubelet` 으로 `--config` 확인)

## 수정
```bash
mv /etc/kubernetes/manifest/audit-agent.yaml /etc/kubernetes/manifests/
sleep 20
crictl pods | grep audit        # sandbox 생성 확인
crictl ps -a | grep agent       # 컨테이너가 없으면 이미지 문제
```
이미지가 안 받아지면(`kubectl -n static-demo describe pod audit-agent-k8s-worker` -> manifest unknown):
```bash
sed -i 's#busybox:1.37.99#busybox:1.37#' /etc/kubernetes/manifests/audit-agent.yaml
```
static pod 는 kubectl 로 수정/삭제할 수 없다. 파일을 고치면 kubelet 이 알아서 재생성.

## 검증
```bash
exit
kubectl -n static-demo get pod audit-agent-k8s-worker -o wide
kubectl -n static-demo get pod audit-agent-k8s-worker -o jsonpath='{.metadata.ownerReferences[0].kind}'   # Node
```

## 포인트
- 이름 규칙: `<pod name>-<node name>`.
- static pod 의 namespace 는 매니페스트의 `metadata.namespace` 이며 네임스페이스가 먼저 존재해야 mirror pod 가 보인다.

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/ , https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/
