set -uo pipefail
source "$LIB/common.sh"
ns_create k8s pf-lab
term_sh 'rm -rf /home/candidate/q110'
kapply k8s -f - <<'EOT'
apiVersion: v1
kind: ConfigMap
metadata: {name: report-v1-conf, namespace: pf-lab, labels: {exam.q: q110-portforward-debug}}
data:
  default.conf: |
    server { listen 80; location /version { default_type text/plain; return 200 "build-3302\n"; } }
---
apiVersion: v1
kind: ConfigMap
metadata: {name: report-v2-conf, namespace: pf-lab, labels: {exam.q: q110-portforward-debug}}
data:
  default.conf: |
    server { listen 80; location /version { default_type text/plain; return 200 "build-4471\n"; } }
---
apiVersion: v1
kind: Pod
metadata: {name: report-v1, namespace: pf-lab, labels: {app: report, track: v1, exam.q: q110-portforward-debug}}
spec:
  volumes: [{name: conf, configMap: {name: report-v1-conf}}]
  containers:
  - name: web
    image: nginx:1.27
    ports: [{containerPort: 80}]
    volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
---
apiVersion: v1
kind: Pod
metadata: {name: report-v2, namespace: pf-lab, labels: {app: report, track: v2, exam.q: q110-portforward-debug}}
spec:
  volumes: [{name: conf, configMap: {name: report-v2-conf}}]
  containers:
  - name: web
    image: nginx:1.27
    ports: [{containerPort: 80}]
    volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
---
apiVersion: v1
kind: Service
metadata: {name: report, namespace: pf-lab, labels: {exam.q: q110-portforward-debug}}
spec:
  selector: {app: report, track: v1}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: v1
kind: Pod
metadata: {name: sealed, namespace: pf-lab, labels: {app: sealed, exam.q: q110-portforward-debug}}
spec:
  containers:
  - name: app
    image: registry.k8s.io/pause:3.10
    env:
    - {name: LICENSE_TIER, value: "gold-7731"}
EOT
