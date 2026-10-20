# q109 - 해설 (kubectl exec, 멀티 컨테이너)

## 핵심
컨테이너가 둘 이상이면 `-c <컨테이너>` 를 반드시 지정한다 (생략하면 첫 컨테이너 `app` 이 선택되고 "Defaulted container" 안내가 나온다). 명령은 `--` 뒤에 쓴다.

```bash
mkdir -p ~/q109
# 1) app 컨테이너의 환경변수
kubectl -n exec-lab exec orders -c app -- printenv APP_REGION > ~/q109/region.txt
# 2) audit 컨테이너의 로그 파일에서 DENIED 개수 (로컬 파이프가 아니라 컨테이너 안에서 실행)
kubectl -n exec-lab exec orders -c audit -- grep -c DENIED /var/log/audit/audit.log > ~/q109/denied-count.txt
# 3) 같은 Pod 은 네트워크 네임스페이스를 공유 -> audit 에서 127.0.0.1 로 app 에 접근
kubectl -n exec-lab exec orders -c audit -- wget -qO- http://127.0.0.1/ | sed -n 's#.*<title>\(.*\)</title>.*#\1#p' > ~/q109/title.txt
# 4) 파일 생성
kubectl -n exec-lab exec orders -c app -- touch /tmp/inspected
```

## 검증
```bash
cat ~/q109/*.txt
kubectl -n exec-lab exec orders -c app -- ls -l /tmp/inspected
kubectl -n exec-lab get pod orders           # RESTARTS 0
```

## 포인트
- `kubectl exec -it pod -c name -- sh` 로 쉘에 들어가도 된다. 쉘이 없는 이미지는 `kubectl debug` (q110) 를 쓴다.
- 파이프(`|`)는 로컬에서 실행된다. 컨테이너 안에서 파이프를 쓰려면 `-- sh -c '...'`.
- 같은 Pod 의 컨테이너는 localhost 와 emptyDir 볼륨을 공유하지만 파일시스템(이미지)은 공유하지 않는다.

문서: https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/
