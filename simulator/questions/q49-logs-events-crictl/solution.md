# q49 - 해설 (logs / events / crictl)

## 진단 순서와 명령
```bash
mkdir -p /home/candidate/q49
# 1. 멀티 컨테이너 pod 는 -c 로 컨테이너 지정
kubectl -n logs-lab logs multi -c shipper > /home/candidate/q49/shipper.log
# 2. 이전 인스턴스 로그
kubectl -n logs-lab logs crasher --previous > /home/candidate/q49/crasher-previous.log
# 3. Warning 이벤트, 시간순
kubectl -n logs-lab get events --field-selector type=Warning --sort-by=.lastTimestamp > /home/candidate/q49/warnings.txt
# 4. 컨테이너별 사용량 (metrics-server 필요, 값이 나오기까지 약 1분)
kubectl -n logs-lab top pod multi --containers > /home/candidate/q49/top.txt
```
5. 노드에서 crictl:
```bash
ssh k8s-node1
sudo -i
crictl ps --name shipper                       # 짧은 ID(13자)
crictl ps --no-trunc -q --name '^shipper$'     # 전체 64자 ID 만 출력
mkdir -p /opt/cka
crictl ps --no-trunc -q --name '^shipper$' > /opt/cka/q49-shipper-id.txt
cat /opt/cka/q49-shipper-id.txt
crictl logs $(cat /opt/cka/q49-shipper-id.txt) | tail    # 확인(선택)
```
참고: `crictl pods`, `crictl inspect <id>`, `crictl logs --tail 20 <id>`. kubectl 이 안 될 때(apiserver 장애) 대신 쓰는 도구.

## 검증
```bash
head -3 /home/candidate/q49/*.log ; cat /home/candidate/q49/warnings.txt /home/candidate/q49/top.txt
```

## 포인트
- stdout 과 stderr 둘 다 `kubectl logs` 에 섞여 나온다. 컨테이너가 여러 개면 `-c` 필수 (`--all-containers` 는 섞임).
- `--previous` 가 재시작 직후 `unable to retrieve container logs for containerd://...` 로 실패하면 몇 초 뒤 다시 실행하고, 파일에 `fatal: license key missing` 이 들어갔는지 `cat` 으로 확인한다.
- `--previous` 는 재시작된 컨테이너의 직전 인스턴스. CrashLoopBackOff 원인 확인의 핵심.
- 이벤트는 기본 정렬이 없다 -> `--sort-by=.lastTimestamp`.

문서: https://kubernetes.io/docs/concepts/cluster-administration/logging/ , https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/ , https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/ , https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/
