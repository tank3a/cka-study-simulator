# CKA 학습 가이드 + 시험 환경 시뮬레이터

CKA(Certified Kubernetes Administrator) 시험을 2주 안에 준비하기 위한 학습 자료와, 내 PC에서 돌리는 시험 연습 환경입니다.
설명은 한국어, 명령어와 문서 링크는 영어 그대로입니다.

- 시험 기준: 커리큘럼 v1.37 (Troubleshooting 30%, Cluster Architecture 25%, Services & Networking 20%, Workloads & Scheduling 15%, Storage 10%)
- 구성: 14일 학습 계획, 하위 역량 27개 학습 노트, 연습 문제 110개(개념 87개, 각 2문제 이상), kind 기반 시뮬레이터, 웹 학습 대시보드
- 검증 상태: 문제 110개 중 107개는 시뮬레이터에서 풀이 스크립트로 끝까지 확인했고, 3개(q34, q100, q102)는 Ingress 컨트롤러가 없어 설정 값만 채점합니다. 자세한 내용은 [`simulator/docs/VERIFICATION.md`](simulator/docs/VERIFICATION.md)
- 사람이 직접 풀어 본 소요 시간은 측정하지 않았습니다. 학습 노트는 직접 실행해 확인했지만 일부 문장은 "(미확인)"으로 표시되어 있습니다.

## 무엇을 보면 되나

| 위치 | 내용 | 언제 |
|---|---|---|
| [`GUIDE.html`](GUIDE.html) | 전체 구성과 하루 학습 루틴 안내 (브라우저로 열기) | 처음 한 번 |
| [`study-guide.md`](study-guide.md) | 시험 정보, 한국 합격자 노하우, 14일 계획 | 계획을 짤 때 |
| [`study-notes/`](study-notes) | 하위 역량(A1~E3) 27개별 노트: 공부할 것, 개념, 예시, 공식 문서 찾는 법, 흔한 실수, 빠르게 푸는 순서 | 그날 주제를 공부할 때 |
| [`simulator/questions/`](simulator/questions) | 문제 110개 (`question.md`, `solution.md`, 채점 스크립트). 목록은 `INDEX.md`, 개념별 매핑은 `COVERAGE.md` | 풀 때 |
| [`research/`](research) | 공식 자료와 한국 후기를 조사한 근거 | 출처가 궁금할 때 |

## 준비물

- macOS (Apple Silicon에서 검증했습니다. Intel과 Linux는 시험하지 않았습니다)
- Docker Desktop (VM 메모리 6GB 이상), `kind`, `kubectl`, `helm`, `jq`, `python3`
- 처음 한 번은 인터넷이 필요합니다 (이미지, 차트, 매니페스트 다운로드, 약 4분)
- 선택: 대시보드 안에서 터미널을 쓰려면 `brew install ttyd`

## 시작하기

```bash
git clone https://github.com/tank3a/cka-study-simulator.git
cd cka-study-simulator/simulator

bin/sim up          # 이미지 빌드, 클러스터 2개(k8s, ek8s), 애드온, 시험 터미널 (처음 약 4분)
bin/sim doctor      # 상태 점검. 실패 항목이 없어야 합니다
```

`assets-cache/`(차트, 매니페스트, 오프라인 패키지 저장소)와 ssh 키는 저장소에 들어 있지 않습니다. `bin/sim up`이 처음 실행할 때 내려받거나 만들도록 되어 있습니다. 다만 새로 clone한 폴더에서 처음부터 실행해 보지는 않았습니다. 막히면 Issues에 남겨 주세요.

## 매일 쓰는 방법

### 1) 학습 대시보드 (권장)

```bash
bin/web             # 출력되는 http://127.0.0.1:8765/?token=... 주소를 브라우저로 엽니다
```

- 홈: 14일 계획. 일차마다 연관 개념과 그날 풀 문제가 나옵니다.
- 학습 노트: 일차의 `study notes` 버튼. 개념, 예시, 공식 문서에서 찾는 법이 나옵니다.
- 문제 페이지: `Start` → 터미널에서 풀기 → `Grade` → (막히면) `Solution`. `Reset`은 이 문제만 처음 상태로 되돌립니다.
- 풀이는 채점을 한 번 하거나 "포기" 체크를 해야 열립니다.
- 같은 PC에서만 접속되고(127.0.0.1), 주소의 token이 있어야 버튼이 동작합니다.
- 화면 안 터미널은 `ttyd`가 있을 때만 나옵니다. 없으면 아래 터미널 명령을 쓰세요.

### 2) 시험 터미널

```bash
bin/sim term        # 시험과 비슷한 터미널(tmux) 접속. 사용자 candidate
```

터미널 안에서 쓰는 명령: `exam q`(문제 보기), `exam check`(채점), `exam reset`(이 문제 초기화), `exam next` / `exam prev`, `ssh k8s-cp` 후 `sudo -i`(노드 작업). `k`는 kubectl 별칭입니다.
컨텍스트는 문제마다 `kubectl config use-context ...`로 바꿉니다 (`k8s`, `mk8s`, `wk8s`, `ek8s`).

### 3) 문제를 터미널에서만 풀고 싶을 때

```bash
bin/exam practice q01-pv-pvc-deployment   # 한 문제, 시간 제한 없음, 채점 상세 표시 (문제 id 전체 이름)
bin/exam solution 1 --force               # 풀이 보기 (호스트에서만)
```

### 4) 모의시험 (2시간)

```bash
bin/exam start mock-a        # 미리 만든 세트. mock-b도 있습니다
bin/mkset my-set             # 문제은행에서 16문항 세트를 새로 만들기 (충돌하는 문제는 같이 넣지 않음)
bin/exam start my-set
```

타이머가 도는 동안은 채점 상세가 숨겨지고(`exam check`는 "checked"만 표시), `exam end`를 하면 점수표가 나옵니다. 합격선은 66%입니다.

## 처음부터 다시 풀기, 다른 문제에 영향을 줄 때

| 상황 | 방법 |
|---|---|
| 지금 문제만 처음부터 다시 | 문제 페이지의 `Reset` 또는 `exam reset` |
| 이전 문제가 바꿔 둔 것(노드 label/taint, kubelet, CoreDNS 등)을 지우고 싶다 | `bin/exam cleanup` |
| 새 문제 시작 | `Start` / `bin/exam practice`가 시작 전에 직전 세션의 변경을 자동으로 되돌립니다 (`--no-clean`으로 끔) |
| 환경이 이상하다 | `bin/sim doctor`로 점검 |
| 클러스터를 통째로 새로 | `bin/sim recreate k8s` (또는 `ek8s`) |

대부분의 문제는 자기 네임스페이스 안에서만 움직입니다. 노드 설정, 컨트롤 플레인, etcd, CoreDNS, metrics-server를 바꾸는 문제는 클러스터 전체에 영향을 주므로 한 번에 하나씩 풀고 끝나면 `Reset` 또는 `exam cleanup`을 하세요. 같은 세트에 넣으면 안 되는 문제는 각 문제 페이지와 `simulator/questions/INDEX.md`의 "Set conflicts"에 있습니다.

## 끄고 켜기

```bash
bin/sim down all    # 클러스터 삭제 (메모리 약 3GB 반환). 이 시뮬레이터가 만든 컨테이너만 지웁니다
bin/sim up          # 다시 켜기 (약 4분)
bin/sim status      # 현재 상태
```

`ik8s`(CNI 설치와 kubeadm 업그레이드 연습용 클러스터)는 평소에는 꺼 둡니다. 해당 문제를 풀 때만 `bin/sim up ik8s`로 켜고, 끝나면 `bin/sim down ik8s`로 끕니다.

## 한계 (시험과 다른 점)

- 시험은 VM이고 여기는 Docker 컨테이너라서 `modprobe`, 스왑, 재부팅 같은 노드 작업은 그대로 따라 할 수 없습니다.
- 클러스터는 Kubernetes v1.34.0이고 시험은 v1.37입니다. 출력 형식이 조금 다를 수 있습니다.
- Ingress 컨트롤러는 설치되어 있지 않습니다 (Gateway API는 NGINX Gateway Fabric). LoadBalancer의 EXTERNAL-IP는 계속 `<pending>`입니다.
- 채점 기준은 공개된 시험 채점표가 아니라 제가 정한 것입니다.
- 실제 시험의 컨텍스트 개수, 메모장·플래그 기능, `.vimrc`와 tmux 사용 가능 여부는 공식 자료에서 확인하지 못했습니다.
- 자세한 목록: [`simulator/docs/KNOWN_LIMITS.md`](simulator/docs/KNOWN_LIMITS.md)

## 문제가 생기면

| 증상 | 확인 |
|---|---|
| `bin/sim up`이 실패 | Docker Desktop이 켜져 있는지, VM 메모리가 6GB 이상인지 |
| 대시보드 버튼이 안 눌림 | 터미널에 출력된 `?token=` 주소로 다시 접속 |
| 터미널에서 `exam check`가 멈춤 | 호스트 데몬 확인: `bin/exam daemon-ensure` |
| 한 노드의 Pod만 DNS가 안 됨 | `kubectl -n kube-system delete pod -l app=kindnet --field-selector spec.nodeName=<노드>` |
| 포트 8765 사용 중 | `bin/web --port 9000` |

## 라이선스와 출처

공식 문서(kubernetes.io, helm.sh, gateway-api.sigs.k8s.io)는 링크로만 연결합니다. 강의 PDF 같은 제3자 자료는 포함하지 않았습니다.
라이선스 파일은 아직 없으므로, 재사용하려면 저장소 소유자에게 문의하세요.
