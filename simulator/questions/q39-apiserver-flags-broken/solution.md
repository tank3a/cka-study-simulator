# q39 - 해설 (kube-apiserver static pod 장애)

## 진단 순서
1. `kubectl get nodes` -> connection refused (apiserver 가 안 떠 있음). kubectl 로는 더 볼 수 없다 -> 노드로.
2. `ssh ek8s-cp` -> `sudo -i`
3. 컨테이너 상태: `crictl ps -a | grep kube-apiserver` -> `Exited` 가 반복.
4. 로그: `crictl logs <container-id>` (또는 `/var/log/pods/kube-system_kube-apiserver-*/kube-apiserver/*.log`)
   -> `open /etc/kubernetes/pki/etcd/ca-bundle.crt: no such file or directory`
5. kubelet 쪽: `journalctl -u kubelet -n 50 --no-pager | grep -i apiserver` (static pod 재시작 사유 확인)
6. 매니페스트: `vim /etc/kubernetes/manifests/kube-apiserver.yaml`

## 수정
```bash
ls /etc/kubernetes/pki/etcd/           # 실제 파일명은 ca.crt
sed -i 's#ca-bundle.crt#ca.crt#' /etc/kubernetes/manifests/kube-apiserver.yaml
```
첫 문제를 고친 뒤에도 안 올라오면 다시 `crictl ps -a`/`crictl logs`:
`--secure-port=6444` 는 liveness/readiness probe 와 kubeconfig(6443) 와 불일치 -> `6443` 으로 복구.
```bash
grep -n -- '--secure-port\|probe\|port:' /etc/kubernetes/manifests/kube-apiserver.yaml
sed -i 's#--secure-port=6444#--secure-port=6443#' /etc/kubernetes/manifests/kube-apiserver.yaml
```
kubelet 이 파일 변경을 감지해 자동으로 pod 를 다시 만든다 (재시작 명령 불필요, 1~2분).

## 검증
```bash
watch crictl ps | grep kube-apiserver
exit
kubectl get nodes ; kubectl -n kube-system get pods
kubectl get ns apiserver-fix
```

## 포인트
- apiserver 가 죽으면 `kubectl` 은 쓸 수 없다: `crictl`, `journalctl -u kubelet`, `/var/log/pods` 가 도구.
- 매니페스트를 엉뚱한 곳(예: /tmp)에 백업해 두고 수정, 실수해도 복구 가능. 백업 파일을 manifests 디렉터리에 두면 별도 static pod 로 인식되므로 금지.
- 문제가 여러 개일 수 있다: 고친 뒤 로그를 다시 확인.

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/ , https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
