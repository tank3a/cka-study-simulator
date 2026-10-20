# CKA 학습 가이드 (Kubernetes v1.37 기준)

작성 기준일: 2026-10-18. 출처 태그는 두 가지입니다.

- 공식: [CUR] 커리큘럼 PDF, [LF] 시험 페이지, [TIPS], [FAQ], [RES], [RULES], [UI], [TOS] (`research/official.md`에 URL 정리)
- 한국 후기: [S1]~[S12] (`research/korean-knowhow.md`의 글 목록). S1~S9는 2025~2026 글, S10~S11은 2024, S12는 2023(2025-02 개편 이전).

표기: **UNVERIFIED** = 입력 자료로 확인되지 않음. **corroborated** = 2025년 이후 글 2편 이상에서 확인. **단일 출처** = 1편에서만 확인.

kubectl/YAML 워크플로 예시는 일반적인 kubectl 사용법이며, 시험 중에는 반드시 아래 공식 문서 페이지에서 필드와 옵션을 다시 확인하십시오. 문서 URL은 `official.md`에서 2026-10-18에 HTTP 200으로 확인된 것만 사용했습니다(이번 작업에서 재확인하지는 않았습니다).

---

## 1. 시험 사실 표

| 항목 | 내용 | 출처 |
|---|---|---|
| 형식 | 온라인 감독(proctored), 커맨드라인 기반 performance-based | [LF] |
| 시간 | 2시간 | [LF] [TIPS] [FAQ] |
| 과제 수 | 15~20개 (공식). 후기는 14~17개 | [TIPS]; [S5] |
| 합격 점수 | 66% 이상 | [FAQ]; 후기 [S5][S7] 일치 |
| Kubernetes 버전 | v1.37 (커리큘럼 PDF도 v1.37) | [FAQ] [TIPS] [LF] [CUR] |
| 재응시 | 구매당 1회 무료. 구매 후 12개월 이내 사용. 대기 기간 명시 없음 | [TOS]; [S4][S5][S7][S8] |
| 재채점 | 결과 후 2일 이내 유료 신청, 합격으로 바뀌면 환불 | official.md (exam-results-no-pass 페이지) |
| 유효 기간 | 2년 (2024-04-01 이전 취득은 3년). 결과는 24시간 이내 메일 | [FAQ] |
| 감독 | PSI Bridge + PSI Secure Browser. 모니터 1대, 웹캠+마이크, VM 금지, 다른 앱 종료. 유효한 정부 발급 사진 ID(서명 포함, 이름 일치) | [TIPS] [FAQ] |
| 시험장 규칙 | 조용한 개인 공간, 깨끗한 책상, 타인 없음. 휴대폰/스마트워치 금지, 음식/껌 금지(라벨 없는 투명 병의 물만), 메모 금지, 녹화, 무관용 | [RULES] |
| 환경 | 원격 데스크톱 VM: 터미널, Firefox(허용 문서용), 가상 키보드, VSCodium(확장 금지). 로드 실패 시 "Reset Desktop". 타이머 알림 30/15/5분, 일시정지해도 타이머는 멈추지 않음 | [UI] |
| 호스트 모델 | 과제마다 호스트 지정. `ssh <nodename>`, `exit`로 `base` 복귀, 중첩 ssh 불가, `sudo -i`로 root. kubectl(alias `k`, bash completion), yq, curl, wget, man은 ssh 호스트에 있고 base에는 없음. base 재부팅 금지 | [TIPS] |
| 키 | Ctrl+Alt+W (Ctrl+W 대신), 터미널 복사/붙여넣기 Ctrl+Shift+C/V, Insert 키 비활성, Ctrl+Alt+K는 커서 찾기 | [TIPS] |
| Firefox | Ctrl+F 사용 가능, Simple Translate 확장 있음 | [UI] |
| 클러스터/컨텍스트 개수 | **UNVERIFIED** (공식 페이지에 없음). 각 과제의 안내문(infobox)을 매번 읽을 것 | official.md |
| 시험 중 메모장/플래그 기능 | **UNVERIFIED** | official.md |
| 응시료 | $395 (S4), 2025-02-04 이후 $445 (S7). 후기 기준이며 공식 확인 안 됨 | [S4][S7] **UNVERIFIED(공식)** |
| 난이도 | 2025-02 개편 후 어려워졌다는 평 | [S5][S8] |

### 허용 사이트 [RES]

- https://kubernetes.io/docs
- https://kubernetes.io/blog/
- https://helm.sh/docs
- https://gateway-api.sigs.k8s.io (CKA 전용)
- **Quick Reference 박스**: 과제 안내문에 링크된 과제별 문서. 해당 링크는 허용됩니다.
- 번역된 쿠버네티스 문서 허용(영문 권장). [S11]은 한국어판이 깨져 보였다고 함.
- kubernetes.io/docs 내 검색 기능은 사용 가능, 외부 검색 결과는 열면 안 됨.
- 터미널의 시험 안내, `/usr/share` 아래 man 페이지, 배포판 패키지 설치 가능.
- 문서 내부의 GitHub/외부 링크 이동은 허용되지 않는 것으로 추정 (**UNVERIFIED**, official.md 추론).

### 커리큘럼 변화 [CUR]

v1.35와 v1.37 PDF는 내용이 동일합니다(v1.36은 미확인). 구 v1.24 대비 추가: 워크로드 오토스케일링, Helm/Kustomize, CNI/CSI/CRI, CRD/오퍼레이터, Gateway API, 리소스 사용량 모니터링. etcd 백업/복원과 kubeadm 업그레이드는 명시 bullet에서 빠졌지만 "Manage the lifecycle of Kubernetes clusters"에 포함될 수 있습니다(후기에서는 출제 여부 의견이 갈림, 4장 참고).

---

## 2. 한국 후기 합의 사항

### 2-1. 터미널 설정

| 항목 | 내용 | 신뢰도 |
|---|---|---|
| `alias k=kubectl` | [S10][S11] (둘 다 2024). 시험 호스트에는 `k` alias와 completion이 이미 있음 [TIPS] | corroborated(2024) + 공식 |
| `export do="--dry-run=client -o yaml"` | alias 자체는 [S11]만. `--dry-run=client -o yaml`로 뼈대 생성은 [S5][S6][S11] | do 변수는 단일 출처, dry-run 방식은 corroborated |
| `export now="--force --grace-period 0"` | [S10] alias, [S11] export 형태 (2024) | corroborated(2024) |
| `alias kd='k describe'`, `alias ka='kubectl apply -f'` | [S11], [S10] | 단일 출처 |
| vim 설정 | [S12]: 연습용 `.vimrc`를 직접 설정해야 한다는 내용은 검색 요약 기반이라 **UNVERIFIED**. [S10]은 `%s/old/new` 일괄 치환 사용 | UNVERIFIED |
| tmux | 읽은 12편 중 언급 없음. **UNVERIFIED** | UNVERIFIED |
| bash completion | 시험 호스트에 이미 있음 [TIPS]. 후기 본문에서는 확인 안 됨 | 공식만 |
| 복사/붙여넣기 | 터미널 Ctrl+Shift+C/V [S4][S11][TIPS]. 우클릭 [S4]. 안 되면 Ctrl+Insert/Shift+Insert [S5] (단 [TIPS]는 Insert 키 비활성이라 함, 충돌, 환경에서 확인). 문제의 이름/코드 블록 클릭 시 복사 [S4][S11][S12]. Mac은 control+c [S6] | corroborated |

권장 설정 (후기 기반 제안, 호스트에 이미 있는 것은 생략 가능):

```bash
# ssh 호스트 또는 base 터미널에서 (kubectl은 ssh 호스트에만 있음 [TIPS])
alias k=kubectl
export do="--dry-run=client -o yaml"
export now="--force --grace-period 0"
# vim 설정 (UNVERIFIED: .vimrc 필요 여부) - 흔히 쓰는 YAML용 설정
cat >> ~/.vimrc <<'EOF'
set expandtab
set tabstop=2
set shiftwidth=2
EOF
source <(kubectl completion bash); complete -o default -F __start_kubectl k
```

ssh로 새 노드에 들어가면 설정이 사라질 수 있으므로 필요 시 다시 입력합니다(UNVERIFIED).

### 2-2. 시간 전략

- 2시간 / 14~17개 = 과제당 약 6분. 빈 문제를 남기지 말 것(부분 점수) [S5] 단일 출처.
- 막히면 넘기고 끝까지 푼 뒤 돌아오기 [S8][S11] **corroborated**. [S11]은 NetworkPolicy에서 5분 헤맨 뒤 넘김.
- 마지막에 남은 시간으로 만든 리소스 재검토 [S6] 단일 출처.
- 시간이 빠듯했다 [S3][S6] **corroborated**. 시험이 1시간 만에 끝난 사례도 있음 [S10].
- 명령형 kubectl로 뼈대를 만들고 빠진 옵션만 문서에서 찾기 [S2][S3][S5][S10] **corroborated**. 문서 검색 속도도 실력 [S3]. 환경 반응이 느리므로 명령어는 외우기 [S8].
- 문서에서 찾기 어려운 항목(Gateway TLS)은 검색 키워드를 미리 외우기 [S5][S8] **corroborated**.
- 학습 기간: 처음이면 2~3개월 [S1][S5] **corroborated**. 직장 병행 약 1개월 [S7], 2주 [S9] 단일 출처.
- killer.sh: 등록 시 2회 세션, 36시간 [S4][S9][S11]. 실제보다 어렵다 [S7][S9][S10][S11] **corroborated**.

### 2-3. 자주 하는 실수

| 함정 | 출처 | 신뢰도 |
|---|---|---|
| 잘못된 노드/호스트에서 작업 (ssh 종료 안 함) | [S10][S5] | corroborated |
| 문제마다 `kubectl config use-context` 누락 (첫 줄 명령 그대로 복사) | [S11]; [S8]은 검색 요약 기반 | 단일 출처 (2024) |
| "하지 말라" 조건 놓침 | [S2] | 단일 출처 |
| 실수로 리소스 삭제 | [S3] | 단일 출처 |
| sidecar 추가 시 initContainers 처리 (Pod이 Running 안 됨) | [S8] | 단일 출처 |
| PV/PVC는 Pod이 사용해야 Bound | [S2] | 단일 출처 |
| CRD 출력 형식 요구 누락 | [S8] | 단일 출처 |
| Deployment label 변경 시 Pod 재생성 필요 | [S11] | 단일 출처 (2024) |
| 인터넷 끊김으로 일부 문제 손상 | [S2] | 단일 출처 |
| 환경 점검 20~40분, 30분 일찍 입실 | [S1][S4][S8] | corroborated |
| 사전 신분증/ID 준비 (여권 등록 권장) | [S5] | 단일 출처 |
| 재응시 일정이 응시권 만료 이후로 밀림 | [S5] | 단일 출처 |
| Mac ScreenSharingSubscriber 문제, Apple 기기 끄기 | [S8] | 단일 출처 |

---

## 3. 도메인별 커리큘럼

가중치(공식 [CUR][LF]): Troubleshooting 30%, Cluster Architecture, Installation & Configuration 25%, Services & Networking 20%, Workloads & Scheduling 15%, Storage 10%. 이 가이드는 모든 하위 역량을 동일하게 다룹니다.

**깨진 URL (사용 금지)**
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage : 404. 대체 https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- https://gateway-api.sigs.k8s.io/api-types/httproute/ : 404. 대체 https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/ (또는 https://gateway-api.sigs.k8s.io/guides/getting-started/introduction/)

리다이렉트되는 URL(접속은 가능, 정식 주소): `/docs/tasks/run-application/horizontal-pod-autoscale/` -> `/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/`; `/docs/concepts/architecture/cri/` -> `/docs/concepts/containers/cri/`.

모든 문서는 `https://kubernetes.io` 도메인(별도 표기 제외)이며 [RES]에서 허용됩니다.

### 3-A. Troubleshooting (30%)

#### A1. Troubleshoot clusters and nodes
1. 개념: 노드 NotReady, kubelet 정지, 런타임 문제 진단. 후기 빈출 [S1][S2][S4][S6].
2. 워크플로: `k get nodes` -> `k describe node <n>` (Conditions 확인) -> `ssh <n>` -> `sudo -i` -> `systemctl status kubelet` -> `journalctl -u kubelet -e --no-pager` -> 원인 수정(`systemctl restart kubelet`, 설정/경로 오류 수정) -> `exit`로 base 복귀. 컨테이너 런타임 확인은 `crictl ps -a`.
3. 문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/ ; https://kubernetes.io/docs/concepts/architecture/nodes/ ; https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
4. 함정: 작업 후 ssh 종료 [S10]. 잘못된 노드 주의. kubelet 설정 파일 위치 등은 문서(kubelet-config-file 페이지)에서 확인. 이 하위 항목의 구체적 원인 종류는 후기에 없으므로 **UNVERIFIED**.

#### A2. Troubleshoot cluster components
1. 개념: kube-apiserver, scheduler, controller-manager, etcd 등 컨트롤 플레인 구성요소 문제.
2. 워크플로: `k get pods -n kube-system` -> 안 뜨면 control-plane 노드에서 `crictl ps -a`, `crictl logs <id>` -> static Pod 매니페스트(kubeadm 환경에서 일반적으로 `/etc/kubernetes/manifests/`) 수정(경로는 `official.md`에 없으므로 문서/환경에서 확인) -> kubelet이 자동 재생성.
3. 문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/ ; https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ ; https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/
4. 함정: apiserver가 죽으면 kubectl이 응답하지 않으므로 crictl/journalctl 사용. 매니페스트의 오타(인자, 경로, 포트) 점검.

#### A3. Monitor cluster and application resource usage
1. 개념: metrics-server 기반 `kubectl top`.
2. 워크플로: `k top node`, `k top pod -A --sort-by=cpu`, `k top pod -n <ns> --containers`. 동작하지 않으면 metrics API 파이프라인 확인.
3. 문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/ ; https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/
4. 함정: metrics-server가 없으면 `top`이 실패. 결과를 파일로 저장하라는 요구 시 경로/형식 준수([S8] CRD 형식 사례 참고).

#### A4. Manage and evaluate container output streams
1. 개념: 컨테이너 로그, 종료 사유.
2. 워크플로: `k logs <pod> -c <ctr>`, `--previous`, `-f`, `--tail=N`; `k logs -l app=x --all-containers`; `k describe pod`(Events, 종료 코드); `k get events --sort-by=.lastTimestamp`; `k exec -it <pod> -- sh`; 임시 디버깅은 `k debug`.
3. 문서: https://kubernetes.io/docs/concepts/cluster-administration/logging/ ; https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/ ; https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/
4. 함정: 재시작된 컨테이너는 `--previous`. 멀티 컨테이너는 `-c` 필수. 출력 저장 경로 지정을 지킬 것.

#### A5. Troubleshoot services and networking
1. 개념: Service가 Pod에 닿지 않는 원인(selector, endpoints, port, DNS, NetworkPolicy).
2. 워크플로: `k get svc,endpoints,endpointslices -n <ns>` -> 비어 있으면 `k get pods --show-labels`로 selector 비교 -> `targetPort` 확인 -> 클러스터 내부에서 `k run tmp --rm -it --image=busybox -- nslookup <svc>` -> NetworkPolicy 확인 `k get netpol`.
3. 문서: https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/ ; https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
4. 함정: 올바른 네임스페이스. selector 오타가 가장 흔한 원인(일반론, 후기 근거는 없음 **UNVERIFIED**).

### 3-B. Cluster Architecture, Installation & Configuration (25%)

#### B1. Manage role based access control (RBAC)
1. 개념: Role/ClusterRole, RoleBinding/ClusterRoleBinding, ServiceAccount. 2025 이후 후기에서는 출제 확인 안 됨 [S11 2024만].
2. 워크플로: `k create role r --verb=get,list --resource=pods -n ns`; `k create rolebinding rb --role=r --serviceaccount=ns:sa -n ns`; 클러스터 범위는 `clusterrole`/`clusterrolebinding`; 검증 `k auth can-i get pods --as=system:serviceaccount:ns:sa -n ns`.
3. 문서: https://kubernetes.io/docs/reference/access-authn-authz/rbac/ ; https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/
4. 함정: 서비스계정은 `ns:name` 형식. Role과 ClusterRole 혼동. 네임스페이스 누락.

#### B2. Prepare underlying infrastructure for installing a Kubernetes cluster
1. 개념: 노드 사전 준비(컨테이너 런타임, kubeadm/kubelet/kubectl 설치, 커널 설정).
2. 워크플로: 문서의 설치 절차를 순서대로 따르기. 패키지 저장소 설정 -> 설치 -> `apt-mark hold`(문서 확인) -> 런타임 설정(cgroup 드라이버 등 문서에서 확인).
3. 문서: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/ ; https://kubernetes.io/docs/setup/production-environment/container-runtimes/
4. 함정: 후기에서 구체적 출제는 확인되지 않음(**UNVERIFIED**). 명령은 문서에서 복사.

#### B3. Create and manage Kubernetes clusters using kubeadm
1. 개념: `kubeadm init` / `join`, CNI 설치. CNI(Calico) 설치 출제 [S2][S5][S8] corroborated.
2. 워크플로: control-plane에서 `kubeadm init`(옵션은 문서) -> kubeconfig 설정 -> CNI 매니페스트 적용 -> worker에서 `kubeadm join`(토큰 분실 시 `kubeadm token create --print-join-command`).
3. 문서: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/ ; CNI 애드온 목록 https://kubernetes.io/docs/concepts/cluster-administration/addons/
4. 함정: CNI 없이는 노드가 Ready가 되지 않음. 설치 매니페스트는 과제 안내/Quick Reference 링크를 우선.

#### B4. Manage the lifecycle of Kubernetes clusters
1. 개념: kubeadm 업그레이드, 인증서, 노드 drain, etcd 백업/복원. 출제 여부는 글마다 상이: etcd [S4][S7][S5] 출제, [S8] 미출제, [S11] 복원 후 실패; kubeadm 업그레이드 [S4][S11] 출제, [S8] 미출제.
2. 워크플로: 업그레이드: `kubectl drain <n> --ignore-daemonsets` -> 패키지 업그레이드, `kubeadm upgrade plan/apply` (워커는 `upgrade node`) -> kubelet 재시작 -> `kubectl uncordon`. etcd: `etcdctl snapshot save/restore`(인증서 경로 옵션 필요, 문서 확인). 인증서: `kubeadm certs check-expiration`.
3. 문서: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/ ; https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/ ; https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/ ; https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
4. 함정: 복원 후 etcd 데이터 디렉터리 경로를 static Pod 매니페스트에 반영해야 하는지 문서에서 확인(복원 실패 사례 [S11]). 업그레이드는 한 마이너 버전씩.

#### B5. Implement and configure a highly-available control plane
1. 개념: stacked etcd vs external etcd 토폴로지, 로드밸런서 엔드포인트.
2. 워크플로: 토폴로지 이해 -> `kubeadm init --control-plane-endpoint` 및 추가 control-plane join 절차를 문서에서 따라가기.
3. 문서: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/ ; https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/
4. 함정: 후기에서 출제 확인 안 됨(**UNVERIFIED**). 개념(토폴로지 차이)을 중심으로.

#### B6. Use Helm and Kustomize to install cluster components
1. 개념: Helm(Argo CD 차트, `helm template`) 출제 [S2][S5][S8] corroborated. Kustomize는 후기 언급 없음.
2. 워크플로: `helm repo add`, `helm repo update`, `helm search repo`, `helm show values <chart>`, `helm install <rel> <chart> -n <ns> --create-namespace --set k=v`(또는 `-f values.yaml`), `helm template ... > out.yaml`, `helm list -A`, `helm upgrade/uninstall`. Kustomize: `kustomization.yaml` 작성 -> `k kustomize <dir>` / `k apply -k <dir>`.
3. 문서: https://helm.sh/docs/intro/using_helm/ ; https://helm.sh/docs/intro/install/ ; https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
4. 함정: 값(예: CRD 설치 여부)을 요구 조건대로 설정. 요구한 출력 파일 경로 준수.

#### B7. Understand extension interfaces (CNI, CSI, CRI, etc.)
1. 개념: 네트워크/스토리지/런타임 플러그인 인터페이스의 역할 구분. CNI 설치는 B3과 연계.
2. 워크플로: 개념 위주. `crictl`(CRI), `k get csidrivers`, `k get storageclass`, CNI 설정 확인은 문서 참고.
3. 문서: https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/ ; https://kubernetes.io/docs/concepts/cluster-administration/addons/ ; https://kubernetes.io/docs/concepts/storage/volumes/#csi ; https://kubernetes.io/docs/concepts/containers/cri/
4. 함정: 후기에서 개념 문제 출제 확인 안 됨(**UNVERIFIED**).

#### B8. Understand CRDs, install and configure operators
1. 개념: CustomResourceDefinition으로 API 확장, 오퍼레이터 패턴. CRD 출력 형식 요구 누락 감점 [S8].
2. 워크플로: `k get crd`, `k explain <kind>.spec`, `k get <cr> -A`, `k describe crd <name>`; 오퍼레이터는 Helm/매니페스트로 설치 후 CR 생성.
3. 문서: https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/ ; https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/ ; https://kubernetes.io/docs/concepts/extend-kubernetes/operator/
4. 함정: 요구된 출력 형식(예: 특정 필드 추출, `-o jsonpath`)을 정확히 따를 것 [S8].

### 3-C. Services & Networking (20%)

#### C1. Understand connectivity between Pods
1. 개념: 모든 Pod 간 NAT 없는 통신 모델, CNI의 역할.
2. 워크플로: `k get pods -o wide`로 IP 확인 -> `k exec <pod> -- wget -qO- <ip>:<port>`로 검증. NetworkPolicy가 막는지 확인.
3. 문서: https://kubernetes.io/docs/concepts/cluster-administration/networking/ ; https://kubernetes.io/docs/concepts/services-networking/
4. 함정: Pod 이미지에 curl이 없을 수 있음(busybox wget 활용, 일반론 **UNVERIFIED**).

#### C2. Define and enforce Network Policies
1. 개념: 선택된 Pod의 ingress/egress 제한. 출제 [S2][S4][S8] corroborated; namespaceSelector 필요 여부 판단, 3개 매니페스트 중 선택 [S2].
2. 워크플로: 문서 예제 YAML 복사 -> `podSelector`, `policyTypes`, `from`/`to`(namespaceSelector, podSelector, ipBlock), `ports` 수정 -> `k apply` -> 연결 테스트. 과제가 기존 후보 매니페스트 중 고르라면 `k get/describe netpol`로 비교.
3. 문서: https://kubernetes.io/docs/concepts/services-networking/network-policies/ ; https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/
4. 함정: 같은 `from` 항목 안의 selector 결합(AND)과 별도 항목(OR)의 차이를 문서 예제로 확인. 적용 네임스페이스 확인. 시간 낭비 시 넘기기 [S11].

#### C3. Use ClusterIP, NodePort, LoadBalancer service types and endpoints
1. 개념: Service 타입, selector->Endpoints/EndpointSlice.
2. 워크플로: `k expose deploy x --port=80 --target-port=8080 --type=NodePort` 또는 `k create svc nodeport x --tcp=80:8080`; `k get svc,ep`; NodePort 지정은 YAML에서 `nodePort`.
3. 문서: https://kubernetes.io/docs/concepts/services-networking/service/ ; https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/ ; https://kubernetes.io/docs/tutorials/services/connect-applications-service/
4. 함정: `k create svc`는 selector를 `app=<name>`로 설정하므로 실제 라벨과 맞는지 확인.

#### C4. Use the Gateway API to manage Ingress traffic
1. 개념: GatewayClass, Gateway, HTTPRoute. 거의 모든 최근 시험에 출제 [S2], 3편 [S2][S5][S8] corroborated. Ingress를 HTTPRoute로 마이그레이션, TLS 포함.
2. 워크플로: `k get gatewayclass,gateway,httproute -A` -> 문서의 HTTPRoute 예제 복사 -> `parentRefs`, `hostnames`, `rules`(matches, backendRefs) 수정. TLS는 Gateway listener의 `tls`/`certificateRefs`(Secret)를 사용.
3. 문서: https://kubernetes.io/docs/concepts/services-networking/gateway/ ; https://gateway-api.sigs.k8s.io/ ; https://gateway-api.sigs.k8s.io/guides/getting-started/introduction/ ; https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/ (`/api-types/httproute/`는 404)
4. 함정: Gateway TLS 예제는 공식 문서에서 찾기 어려움 [S5][S8] corroborated. 검색 키워드를 미리 정해 연습(예: gateway-api.sigs.k8s.io 사이트의 TLS 관련 가이드 페이지는 이 입력 자료에 URL이 없으므로 **UNVERIFIED**, 시험 전에 직접 찾아 확인).

#### C5. Know how to use Ingress controllers and Ingress resources
1. 개념: Ingress 리소스와 컨트롤러. 후기에서는 Gateway 쪽 출제가 더 두드러짐.
2. 워크플로: `k create ingress NAME --rule="host/path=svc:port"`(`--class` 등), 필요 시 YAML 수정, `k describe ingress`로 backend 확인.
3. 문서: https://kubernetes.io/docs/concepts/services-networking/ingress/ ; https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/
4. 함정: `ingressClassName`, `pathType` 필수 필드. backend Service 이름/포트 일치.

#### C6. Understand and use CoreDNS
1. 개념: 클러스터 DNS, `<svc>.<ns>.svc.cluster.local`, CoreDNS ConfigMap.
2. 워크플로: `k get pods -n kube-system -l k8s-app=kube-dns`(라벨은 일반적 값, 문서 확인) -> `k -n kube-system get cm coredns -o yaml` -> 수정 후 롤아웃 -> `nslookup` 테스트.
3. 문서: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/ ; https://kubernetes.io/docs/tasks/administer-cluster/coredns/ ; https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/
4. 함정: 후기에서 출제 확인 안 됨(**UNVERIFIED**). Corefile 문법 오류 시 CoreDNS가 재시작 루프에 빠질 수 있음(일반론).

### 3-D. Workloads & Scheduling (15%)

#### D1. Understand application deployments and how to perform rolling update and rollbacks
1. 워크플로: `k create deploy x --image=nginx:1.x --replicas=3`; `k set image deploy/x nginx=nginx:1.y`; `k rollout status/history/undo deploy/x [--to-revision=N]`; 전략은 `strategy.rollingUpdate.maxSurge/maxUnavailable`; `k scale`.
2. 문서: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ ; https://kubernetes.io/docs/reference/kubectl/generated/kubectl_rollout/
3. 함정: Deployment selector/label 변경은 Pod 재생성 필요 [S11]. sidecar(emptyDir) 추가 출제 [S2][S4][S8] corroborated: 컨테이너와 volume, volumeMount 모두 추가하고, initContainers를 건드렸다면 상태 확인 [S8].

#### D2. Use ConfigMaps and Secrets to configure applications
1. 워크플로: `k create cm x --from-literal=k=v --from-file=...`; `k create secret generic x --from-literal=...`; Pod에서 `env.valueFrom.configMapKeyRef/secretKeyRef`, `envFrom`, 또는 volume 마운트.
2. 문서: https://kubernetes.io/docs/concepts/configuration/configmap/ ; https://kubernetes.io/docs/concepts/configuration/secret/ ; https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
3. 함정: Secret은 base64. 환경변수는 Pod 재시작 후 반영, 볼륨 마운트는 갱신될 수 있음(일반론, 문서 확인). 2025 이후 CKA 후기 출제 언급은 CKAD 글 [S5]에만 있음.

#### D3. Configure workload autoscaling
1. 개념: HPA(출제 [S2][S5] corroborated, [S2]: 메트릭 타입 resources 판별), VPA 개념.
2. 워크플로: `k autoscale deploy x --min=2 --max=5 --cpu=50%` (kubectl 1.34에서 `--cpu-percent=50`은 deprecated 경고가 나오지만 동작함, `--cpu=50`처럼 %를 빼면 50m 절대값이 됨); 세부 설정(behavior, metrics)은 문서 YAML 사용. 확인 `k get hpa`. 메트릭 필요: metrics-server.
3. 문서: https://kubernetes.io/docs/concepts/workloads/autoscaling/ ; https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/ ; https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/ ; https://kubernetes.io/docs/concepts/workloads/autoscaling/vertical-pod-autoscale/
4. 함정: 대상 Pod에 CPU `requests`가 없으면 사용률 기반 HPA가 동작하지 않음(문서에서 확인).

#### D4. Understand the primitives used to create robust, self-healing, application deployments
1. 개념: ReplicaSet, probes(liveness/readiness/startup), restartPolicy, Pod lifecycle.
2. 워크플로: 문서 예제에서 probe 스니펫 복사 -> `httpGet`/`exec`/`tcpSocket` 및 `initialDelaySeconds`, `periodSeconds` 조정. 확인 `k describe pod` Events.
3. 문서: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/ ; https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ ; https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/
4. 함정: 후기에서 직접 출제 확인 안 됨(**UNVERIFIED**). readiness 실패는 Endpoints에서 제외됨(A5 연계).

#### D5. Configure Pod admission and scheduling (limits, node affinity, etc.)
1. 개념: requests/limits, LimitRange, ResourceQuota, nodeSelector, affinity, taints/tolerations, PriorityClass. PriorityClass/리소스 분배 출제 [S2][S5][S8] corroborated ([S2]: 3개 replica에 allocatable 분배). Taints/nodeSelector [S4] 단일 출처.
2. 워크플로: `k taint nodes n key=val:NoSchedule`; Pod spec에 `tolerations`/`nodeSelector`/`affinity`; `k create priorityclass hi --value=1000`; `k describe node`의 Allocatable/Allocated 확인 후 requests 계산.
3. 문서: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ ; https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ ; https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ ; https://kubernetes.io/docs/concepts/policy/limit-range/ ; https://kubernetes.io/docs/concepts/policy/resource-quotas/ ; https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/
4. 함정: 요청 합계가 allocatable을 넘으면 Pending. `k describe pod` Events에서 스케줄 실패 사유 확인. 노드 drain 출제 [S4][S11].

### 3-E. Storage (10%)

#### E1. Implement storage classes and dynamic volume provisioning
1. 워크플로: `k get sc`; StorageClass YAML(provisioner, reclaimPolicy, volumeBindingMode) 문서 복사; PVC에 `storageClassName` 지정하면 동적 프로비저닝. 기본 SC 지정은 어노테이션(문서 확인).
2. 문서: https://kubernetes.io/docs/concepts/storage/storage-classes/ ; https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/
3. 함정: `WaitForFirstConsumer`이면 Pod이 사용할 때까지 PVC가 Pending [S2]와 같은 맥락(일반론, 문서 확인).

#### E2. Configure volume types, access modes and reclaim policies
1. 개념: emptyDir, hostPath, configMap/secret, PVC 등. accessModes(RWO/ROX/RWX/RWOP), reclaimPolicy(Retain/Delete).
2. 워크플로: Pod spec `volumes` + `volumeMounts`. 정책 변경: `k patch pv x -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'`.
3. 문서: https://kubernetes.io/docs/concepts/storage/volumes/ ; https://kubernetes.io/docs/concepts/storage/persistent-volumes/ (access modes, reclaim policy 절)
4. 함정: sidecar용 emptyDir는 두 컨테이너 모두에 mount [S4][S8].

#### E3. Manage persistent volumes and persistent volume claims
1. 개념: PV 생성, PVC 바인딩, Pod에서 사용. 출제 [S2][S4][S5] corroborated.
2. 워크플로: PV YAML(capacity, accessModes, storageClassName, hostPath) -> PVC YAML(요청 크기, accessModes, storageClassName 일치) -> `k get pv,pvc`로 Bound 확인 -> Deployment/Pod 볼륨에 연결.
3. 문서: https://kubernetes.io/docs/concepts/storage/persistent-volumes/ (configure-persistent-volume-storage 페이지는 404이므로 사용 금지)
4. 함정: PV/PVC는 Pod이 사용해야 Bound [S2] (volumeBindingMode에 따라 다름, 문서 확인). 크기/accessMode/storageClassName 불일치 시 Pending.

---

## 4. 주제별 출제 빈도 (한국 후기, 2025 이후 글 기준)

정확한 비율은 확인되지 않음. 글에 적힌 기억 기준입니다.

| 주제 | 언급 글 | 편수 | 비고 |
|---|---|---|---|
| Gateway API / HTTPRoute (TLS) | S2, S5, S8 | 3 | corroborated, "거의 모든 최근 시험" [S2] |
| Helm (Argo CD, helm template) | S2, S5, S8 | 3 | corroborated |
| NetworkPolicy | S2, S4, S8 | 3 | corroborated |
| PV / PVC / StorageClass | S2, S4, S5 | 3 | corroborated |
| Deployment sidecar (emptyDir) | S2, S4, S8 | 3 | corroborated |
| 노드 NotReady / kubelet 트러블슈팅 | S1, S2, S4, S6 | 4 | corroborated |
| etcd 백업/복원 | S4, S5, S7 출제 / S8 미출제 / S11 복원 실패(2024) | 3 | 의견 충돌 |
| kubeadm 업그레이드 | S4, S11 출제 / S8 미출제 | 2 | 의견 충돌 |
| CNI (Calico 설치) | S2, S5, S8 | 3 | corroborated |
| PriorityClass / 리소스 분배 | S2, S5, S8 | 3 | corroborated |
| HPA | S2, S5 | 2 | corroborated |
| Taints/Tolerations, nodeSelector | S4 | 1 | 단일 출처 |
| RBAC | S11 (2024) | 1 | 2025 이후 미확인 |
| StatefulSet, Multi-container Pod, Node drain | S11 (2024), S4 | 1~2 | |
| CoreDNS, Kustomize, HA control plane, CRD(출력형식만 [S8]) | 거의 없음 | 0~1 | UNVERIFIED |

참고: 후기 빈도와 무관하게 이 가이드는 모든 하위 역량을 동일하게 연습하도록 구성했습니다. 후기는 기억에 의존하며 개편 후 시험이 바뀔 수 있습니다.

---

## 5. 14일 계획

규칙: 도메인 슬라이스당 하루, 하위 역량 27개를 동일한 비중으로 순회(1~10일), 11~14일은 전체 재순회. 연습 문제: 열 "practice questions: see questions/INDEX.md" 참고(q01..q110 중 해당 일에 배정). 이 계획은 2주를 넘겨 연장할 수 있습니다. 처음 준비하는 경우 2~3개월 사례가 많습니다 [S1][S5]. 연장 시 같은 순서를 반복하고 각 일의 시간을 늘리면 됩니다.

각 하위 역량마다 동일한 루틴: (1) 공식 문서 페이지 열어 위치 파악 (2) 명령형으로 해결 (3) 해당 문서를 보며 YAML 수정 (4) 검증 명령 실행.

| Day | 슬라이스 | 하위 역량 | 도구/문서 연습 | practice questions: see questions/INDEX.md |
|---|---|---|---|---|
| 1 | Storage | E1, E2, E3 | SC/PV/PVC 만들고 Pod에 연결, reclaimPolicy 변경 | E1: q02, q04 / E2: q03, q05 / E3: q01, q06 |
| 2 | Troubleshooting 1 | A1, A2 | kubelet 중지/설정 오류 복구, static Pod 매니페스트 오타 복구 | A1: q37, q38, q43 / A2: q40, q41 |
| 3 | Troubleshooting 2 | A3, A4, A5 | `top`, logs/--previous, Service-Endpoint-DNS 점검 | A3: q50 / A4: q42, q49 / A5: q28, q44, q45, q48 |
| 4 | Workloads 1 | D1, D2, D3 | rollout/undo, cm/secret 주입, HPA | D1: q07 / D2: q08 / D3: q09 |
| 5 | Workloads 2 | D4, D5 | probes, taint/toleration, affinity, PriorityClass, requests 계산 | D4: q10 / D5: q11, q12, q13 |
| 6 | Cluster 1 | B1, B2, B3 | RBAC + can-i, 설치 문서 훑기, kubeadm init/join/CNI | B1: q15, q16 / B2: 해당 문항 없음 / B3: q20 |
| 7 | Cluster 2 | B4, B5 | drain/upgrade 절차, etcd snapshot, certs, HA 토폴로지 읽기 | B4: q17, q18 (q18은 마지막, 단독), q19 (ik8s 전용, 기본 세트 제외) / B5: q21 |
| 8 | Cluster 3 | B6, B7, B8 | Helm install/template, Kustomize, CRD 조회, 인터페이스 개념 | B6: q22, q23, q24 / B7: q26 / B8: q25 |
| 9 | Networking 1 | C1, C2, C3 | Pod 통신 테스트, NetworkPolicy, Service 타입 | C1: q36 / C2: q29, q30 / C3: q27 |
| 10 | Networking 2 | C4, C5, C6 | HTTPRoute(+TLS 문서 위치 찾기), Ingress, CoreDNS | C4: q31, q32 / C5: q33, q34 / C6: q35, q46 (q46은 DNS를 깨므로 단독 실행) |
| 11 | 재순회: Storage + Troubleshooting | E1~E3, A1~A5 | 시간 제한(과제당 약 6분) | 세트: q02, q06, q07, q11, q15, q17, q25, q27, q29, q31, q39, q42, q44, q50 (q39는 q37·q40과 같은 세트에 넣지 않음) |
| 12 | 재순회: Workloads + Cluster | D1~D5, B1~B8 | 시간 제한 | 세트: q05, q08, q09, q10, q12, q14, q16, q21, q23, q26, q28, q33, q48, q49 |
| 13 | 재순회: Services & Networking + 혼합 | C1~C6 + 약점 | 시간 제한, 컨텍스트/네임스페이스 확인 습관 | 세트: q04, q13, q22, q27, q30, q31, q35, q36, q45, q49 |
| 14 | 모의 전체 실전 | 전 영역 균등 | 2시간 풀세트, 막히면 넘기기 [S8][S11], 마지막 검토 [S6], 환경 점검(PSI, ID, 책상) | 15문항, 가중치 합 97: q02(5), q03(6), q07(6), q11(6), q14(7), q16(6), q23(7), q25(6), q29(7), q31(7), q35(7), q37(6), q40(7), q43(7), q49(7). 영역: Storage 2, Workloads 3, Cluster 3, Networking 3, Troubleshooting 4. q18·q19·q39·q46 제외(충돌/파괴적), q37+q40은 허용된 조합 |

모의시험 관련: killer.sh는 2회 세션이 포함되며 실제보다 어렵다는 평이 많으므로 [S7][S9][S10][S11] 점수에 일희일비하지 마십시오. 사용 시점은 연습 후반을 권합니다(제안).

---

## Concept → practice questions

The question bank has 110 questions (q01..q110). Each concept in section 3 maps to the practice questions that exercise it: see [simulator/questions/INDEX.md](simulator/questions/INDEX.md) for the merged question table (domain, weight, difficulty, fidelity, doc link, set conflicts) and [simulator/questions/COVERAGE.md](simulator/questions/COVERAGE.md) for the concept-by-question matrix. Every concept has at least 2 questions; concepts marked as partial or low fidelity in COVERAGE.md are only partly testable on the kind lab.

## 부록: 확인되지 않은 항목 요약

- 시험의 클러스터/컨텍스트 개수, 시험 중 메모장/플래그 기능
- `.vimrc` 필요 여부, tmux 설치 여부, ssh 후 alias 유지 여부
- Insert 키 단축키 충돌([S5] vs [TIPS])
- 응시료의 공식 금액
- v1.36 커리큘럼 diff, 개편 정확한 적용일
- Gateway TLS 관련 공식 문서 URL(입력 자료에 없음)
- 후기에서 B2, B5, B7, C6, D4의 출제 여부
