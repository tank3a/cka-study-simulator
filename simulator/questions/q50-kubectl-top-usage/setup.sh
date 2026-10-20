set -uo pipefail
source "$LIB/common.sh"
ns_create k8s top-lab
term_sh 'rm -rf /home/candidate/q50'
kapply k8s -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata: {name: burner-a, namespace: top-lab, labels: {exam.q: q50-kubectl-top-usage}}
spec:
  replicas: 1
  selector: {matchLabels: {app: burner-a}}
  template:
    metadata: {labels: {app: burner-a}}
    spec:
      containers:
      - name: burn
        image: busybox:1.37
        command: ["sh", "-c", "while :; do :; done"]
        resources:
          requests: {cpu: 50m}
          limits: {cpu: 400m}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: burner-b, namespace: top-lab, labels: {exam.q: q50-kubectl-top-usage}}
spec:
  replicas: 1
  selector: {matchLabels: {app: burner-b}}
  template:
    metadata: {labels: {app: burner-b}}
    spec:
      containers:
      - name: burn
        image: busybox:1.37
        command: ["sh", "-c", "while :; do :; done"]
        resources:
          requests: {cpu: 20m}
          limits: {cpu: 50m}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: memhog, namespace: top-lab, labels: {exam.q: q50-kubectl-top-usage}}
spec:
  replicas: 1
  selector: {matchLabels: {app: memhog}}
  template:
    metadata: {labels: {app: memhog}}
    spec:
      containers:
      - name: hog
        image: busybox:1.37
        command: ["sh", "-c", "x=$(head -c 60000000 /dev/zero | tr '\\0' a); sleep 36000; echo \"${#x}\""]
        resources:
          requests: {memory: 64Mi}
          limits: {memory: 256Mi}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: idle, namespace: top-lab, labels: {exam.q: q50-kubectl-top-usage}}
spec:
  replicas: 2
  selector: {matchLabels: {app: idle}}
  template:
    metadata: {labels: {app: idle}}
    spec:
      containers:
      - {name: idle, image: "busybox:1.37", command: ["sh", "-c", "sleep 36000"]}
EOF
