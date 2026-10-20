# q110 - 해설 (port-forward, kubectl debug)

## 1) kubectl port-forward (Pod 직접 지정)
Service `report` 는 v1 만 가리키므로 Service 로 포워딩하면 v2 에 닿지 않는다. Pod 이름을 직접 지정한다.
```bash
mkdir -p ~/q110
kubectl -n pf-lab port-forward pod/report-v2 18080:80 &      # 형식: 로컬포트:Pod포트
sleep 2
curl -s http://127.0.0.1:18080/version > ~/q110/v2-version.txt
kill %1                                                       # 포워드 종료
cat ~/q110/v2-version.txt                                     # build-4471
```
(터미널을 하나 더 열어 foreground 로 실행해도 된다.) `Unable to listen on port` 면 포트가 이미 사용 중.

## 2) kubectl debug (ephemeral container)
`sealed` 는 pause 이미지라 `kubectl exec ... sh` 가 실패한다 (`executable file not found`).
```bash
kubectl -n pf-lab debug -it sealed --image=busybox:1.37 --target=app --profile=general -- sh
# 디버그 컨테이너 안에서 (--target 으로 app 의 프로세스 네임스페이스를 공유):
cat /proc/1/environ | tr '\0' '\n' | grep LICENSE_TIER
exit
```
비대화형으로 한 번에:
```bash
kubectl -n pf-lab debug sealed --image=busybox:1.37 --target=app --profile=general -q -i -- sh -c "tr '\0' '\n' </proc/1/environ | sed -n 's/^LICENSE_TIER=//p'" > ~/q110/license.txt
```
(`-q` 로 안내 문구를 숨긴다. 값이 안 나오면 `-it` 로 쉘에 들어가 직접 확인 후 파일에 기록해도 된다.)

## 검증
```bash
cat ~/q110/*.txt
kubectl -n pf-lab get pod sealed -o jsonpath='{.spec.ephemeralContainers[*].name}'
kubectl -n pf-lab get pod sealed        # RESTARTS 0
```

## 포인트
- `--profile=general` 이 필요하다: 기본(legacy) 프로파일의 디버그 컨테이너는 SYS_PTRACE 가 없어 다른 UID(pause=65535)의 `/proc/1/environ` 읽기가 `Permission denied` 가 된다. general 은 SYS_PTRACE 를 추가한다.
- `--target` 없이는 다른 컨테이너의 프로세스가 보이지 않는다. ephemeral container 는 Pod 에서 삭제할 수 없고 Pod 재생성 시 사라진다.
- `--copy-to` 는 Pod 사본을 만들어 명령/이미지를 바꿔 디버깅할 때 쓴다 (이 문제에서는 금지).
- `kubectl port-forward svc/<name>` 는 Service 뒤의 Pod 하나를 고른다. 특정 Pod 을 보려면 `pod/<name>`.

문서: https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/
