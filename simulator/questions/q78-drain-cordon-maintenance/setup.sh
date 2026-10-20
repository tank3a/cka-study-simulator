set -uo pipefail
source "$LIB/common.sh"
ns_create k8s drain-lab
kc k8s uncordon k8s-worker2 >/dev/null 2>&1
kc k8s cordon k8s-worker >/dev/null 2>&1
kc k8s -n drain-lab delete pod solo --ignore-not-found --wait=true --timeout=30s >/dev/null 2>&1
kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: drain-lab, labels: {exam.q: "$QID"}}
spec:
  replicas: 4
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      terminationGracePeriodSeconds: 1
      containers:
        - {name: c, image: "busybox:1.37", command: ["sleep","3600"], volumeMounts: [{name: scratch, mountPath: /scratch}]}
      volumes:
        - {name: scratch, emptyDir: {}}
---
apiVersion: apps/v1
kind: DaemonSet
metadata: {name: agent, namespace: drain-lab, labels: {exam.q: "$QID"}}
spec:
  selector: {matchLabels: {app: agent}}
  template:
    metadata: {labels: {app: agent}}
    spec:
      terminationGracePeriodSeconds: 1
      tolerations: [{operator: Exists}]
      containers:
        - {name: c, image: "busybox:1.37", command: ["sleep","3600"]}
YAML
wait_for 90 -- kc k8s -n drain-lab rollout status deploy/web --timeout=5s
kapply k8s -f - <<YAML
apiVersion: v1
kind: Pod
metadata: {name: solo, namespace: drain-lab, labels: {exam.q: "$QID", app: solo}}
spec:
  nodeName: k8s-worker2
  terminationGracePeriodSeconds: 1
  containers:
    - {name: c, image: "busybox:1.37", command: ["sleep","3600"]}
YAML
