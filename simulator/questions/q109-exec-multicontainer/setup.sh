set -uo pipefail
source "$LIB/common.sh"
ns_create k8s exec-lab
term_sh 'rm -rf /home/candidate/q109'
kapply k8s -f - <<'EOT'
apiVersion: v1
kind: Pod
metadata:
  name: orders
  namespace: exec-lab
  labels: {app: orders, exam.q: q109-exec-multicontainer}
spec:
  volumes:
  - name: auditlog
    emptyDir: {}
  containers:
  - name: app
    image: nginx:1.27
    env:
    - {name: APP_REGION, value: "eu-north-1"}
  - name: audit
    image: busybox:1.37
    command: ["sh", "-c", "printf 'ALLOWED u1 read\nDENIED u2 write\nALLOWED u3 read\nDENIED u4 delete\nDENIED u2 admin\nALLOWED u1 write\n' > /var/log/audit/audit.log; sleep 36000"]
    volumeMounts:
    - {name: auditlog, mountPath: /var/log/audit}
EOT
