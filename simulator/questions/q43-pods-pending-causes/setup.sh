set -uo pipefail
source "$LIB/common.sh"
ns_create k8s pending-lab
kc k8s taint node k8s-worker exam-reserved=q43:NoSchedule --overwrite >/dev/null
kapply k8s -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata: {name: big-app, namespace: pending-lab, labels: {exam.q: q43-pods-pending-causes}}
spec:
  replicas: 2
  selector: {matchLabels: {app: big-app}}
  template:
    metadata: {labels: {app: big-app}}
    spec:
      containers:
      - name: app
        image: nginx:1.27
        resources:
          requests: {cpu: "48", memory: 64Mi}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: reporter, namespace: pending-lab, labels: {exam.q: q43-pods-pending-causes}}
spec:
  replicas: 1
  selector: {matchLabels: {app: reporter}}
  template:
    metadata: {labels: {app: reporter}}
    spec:
      nodeSelector: {disktype: ssd}
      containers:
      - name: reporter
        image: busybox:1.37
        command: ["sh", "-c", "sleep 3600"]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: db-data, namespace: pending-lab, labels: {exam.q: q43-pods-pending-causes}}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: fast-ssd
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: db, namespace: pending-lab, labels: {app: db, exam.q: q43-pods-pending-causes}}
spec:
  containers:
  - name: db
    image: busybox:1.37
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts: [{name: data, mountPath: /data}]
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: db-data}
EOF
