# q01 해설: PV + PVC + Deployment (빠른 풀이 워크스루)

목표 풀이 시간: 4~5분 (10분을 넘기면 일단 flag 하고 넘어간다).

## 0. 먼저 알아둘 것
- PV 는 **imperative 명령이 없다** (`kubectl create pv` 없음). PVC 도 마찬가지로 없다. 그래서 YAML 은 문서에서 복사한다.
- Deployment 는 `kubectl create deployment ... --dry-run=client -o yaml` 로 뼈대를 만들고 volume 부분만 문서에서 복사한다.
- 주의: `kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/` 페이지는 **404 (사라짐)**. 열지 말 것.
- 열어야 할 문서 한 페이지: **https://kubernetes.io/docs/concepts/storage/persistent-volumes/**
  (검색창에 `persistent volumes` 입력해도 첫 결과로 나온다.) 이 한 페이지에 PV, PVC, "Claims As Volumes" Pod 예제가 모두 있다.

## 1. 네임스페이스/컨텍스트 확인 (10초)
```bash
kubectl config use-context k8s
kubectl get ns data-app
```

## 2. PV 작성 (문서 복사 + vim 수정, 약 1분 30초)
1. 위 문서 페이지에서 `Ctrl+F` 로 **`pv0003`** 을 검색한다. "Reclaim Policy"/"Class" 설명 근처에 있는 `kind: PersistentVolume` 예제가 나온다
   (`persistentVolumeReclaimPolicy: Recycle`, `storageClassName: slow`, `nfs:` 가 들어 있는 YAML).
   - `pv0003` 이 안 잡히면 `Ctrl+F` 에 **`persistentVolumeReclaimPolicy`** 를 넣어도 같은 블록이 나온다.
2. 블록을 드래그해 복사하고 터미널에서:
```bash
vim pv.yaml        # i 로 insert 모드 후 붙여넣기 (또는 :set paste)
```
3. 다음처럼 고친다 (nfs 블록 전체를 hostPath 로 교체한다):
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data-app
```
   - `volumeMode: Filesystem` 줄은 기본값이므로 지워도 되고 두어도 된다.
   - `mountOptions`, `nfs:` 줄은 반드시 삭제한다 (남기면 `may not specify more than 1 volume type` 에러).
   - hostPath 예제가 필요하면 https://kubernetes.io/docs/concepts/storage/volumes/#hostpath 에서 `Ctrl+F` `hostPath` 로 찾아 `path:` 한 줄 형식을 확인할 수 있다.
4. `kubectl apply -f pv.yaml`

## 3. PVC 작성 (약 1분)
1. 같은 페이지에서 `Ctrl+F` **`myclaim`** → `kind: PersistentVolumeClaim` 예제 (PersistentVolumeClaims 섹션).
2. 복사 후 수정:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-data
  namespace: data-app
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 500Mi
```
   - 예제에 있는 `volumeMode: Filesystem` 은 그대로 두거나 삭제. `selector:` 블록은 이 문제에서는 필요 없으니 **삭제**한다
     (남기면 matchLabels 때문에 Pending 이 된다).
3. `kubectl apply -f pvc.yaml` 후 `kubectl get pvc -n data-app` → `Bound` 확인.
   - 이 PV/PVC 는 `storageClassName: manual` 이 서로 같고, 용량(1Gi >= 500Mi)·accessMode 가 맞으므로 Pod 없이도 Bound 된다.

## 4. Deployment 작성 (약 1분 30초)
뼈대 생성:
```bash
kubectl -n data-app create deployment data-app --image=nginx:1.27 --replicas=1 \
  --dry-run=client -o yaml > d.yaml
vim d.yaml
```
같은 문서 페이지에서 `Ctrl+F` **`Claims As Volumes`** 로 이동 → Pod 예제의 `volumeMounts` / `volumes` 블록을 복사한다.
`d.yaml` 의 `containers:` 아래 (image 줄 다음)와 `containers` 와 같은 들여쓰기에 아래처럼 넣는다:
```yaml
    spec:
      containers:
      - image: nginx:1.27
        name: nginx
        volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: pvc-data
```
- vim 팁: 붙여넣기 전에 `:set paste`, 들여쓰기가 깨지면 `:set ts=2 sw=2 et` 후 `>>` / `<<` 로 맞춘다. 
- `volumes:` 는 `containers:` 와 **같은 레벨** (둘 다 `spec:` 의 자식) 이다. 이게 가장 흔한 실수.
- `kubectl apply -f d.yaml`

(대안: 이미 만든 Deployment 에 `kubectl -n data-app set volume deploy/data-app --add --name=data --type=persistentVolumeClaim --claim-name=pvc-data --mount-path=/usr/share/nginx/html`
 도 동작한다. 단, 시험 중에는 YAML 이 더 예측 가능하다.)

## 5. 검증 (30초)
```bash
kubectl get pv pv-data
kubectl -n data-app get pvc,deploy,pod
kubectl -n data-app describe pod -l app=data-app | grep -A3 -i -E 'Mounts|Volumes'
kubectl -n data-app exec deploy/data-app -- df -h /usr/share/nginx/html
```
기대 결과: PV `Bound`(CLAIM data-app/pvc-data), PVC `Bound`, Deployment `1/1`.

## 6. 자주 하는 실수
- `storageClassName` 오타/불일치 → PVC 가 영원히 `Pending` (PV/PVC 둘 다 `manual` 이어야 한다). 필드를 아예 빼면 default StorageClass(`standard`)가 붙어 동적 프로비저닝이 되므로 **쓰지 않으면 안 된다**.
- PVC 의 `namespace` 누락 (default 네임스페이스에 생성됨). PV 는 cluster-scoped 라 namespace 를 쓰지 않는다.
- PV 가 `Available` 로 남아 있다면 PVC 의 accessModes/용량/storageClassName 중 하나가 안 맞는 것. `kubectl describe pvc` 의 Events 확인.
- `volumes` 의 `name` 과 `volumeMounts` 의 `name` 이 다르면 `unknown volume` 에러.
- PVC 의 `selector` 를 남겨 둬서 Pending.
- 문서 예제의 `persistentVolumeReclaimPolicy: Recycle` 을 그대로 두면 감점 (문제는 `Retain`).
- 삭제된 task 페이지(`configure-persistent-volume-storage`)를 찾느라 시간을 쓰는 것.

## 7. 참고
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- https://kubernetes.io/docs/concepts/storage/volumes/#hostpath
