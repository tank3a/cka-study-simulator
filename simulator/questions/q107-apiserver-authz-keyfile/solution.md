# q107 - 해설 (kube-apiserver 장애 2)

## 진단 순서
kubectl 이 안 되므로 노드에서 container runtime 으로 직접 확인한다.
```bash
ssh ek8s-cp; sudo -i
crictl ps -a | grep kube-apiserver          # Exited, 계속 재시작
crictl logs $(crictl ps -a --name kube-apiserver -q | head -1) 2>&1 | tail
```
- 1차: `invalid argument "Node,RBCA" for "--authorization-mode"` (또는 unknown authorization mode RBCA)
- 수정 후 2차: `open /etc/kubernetes/pki/apiserver.key.bak: no such file or directory`

crictl 컨테이너가 아예 보이지 않으면 `journalctl -u kubelet | tail` 로 매니페스트 파싱 오류를 본다.

## 수정
```bash
ls /etc/kubernetes/pki/ | grep apiserver
vim /etc/kubernetes/manifests/kube-apiserver.yaml
#  --authorization-mode=Node,RBAC
#  --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
```
저장하면 kubelet 이 재생성한다 (최대 1-2분). 매니페스트를 다른 곳으로 옮기거나 이름을 바꾸지 않는다.

## 검증
```bash
crictl ps | grep kube-apiserver
kubectl get --raw=/readyz
kubectl get nodes; kubectl get ns apiserver-fix2
```

## 포인트
- q39 와 같은 절차이지만 원인이 다르다: 인자 값 오류(crash)와 파일 경로 오류. 로그를 한 번에 하나씩 해결한다.
- 수정 전 매니페스트를 `cp` 로 백업하되 **/etc/kubernetes/manifests 밖**에 둔다 (안에 두면 kubelet 이 추가 Pod 으로 읽는다).

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/ , https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
