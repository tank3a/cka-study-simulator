#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s secret-demo
kapply k8s -f - <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: secret-demo
  labels: {exam.q: "$QID"}
YAML
term_sh 'mkdir -p /home/candidate/certs && [ -s /home/candidate/certs/tls.crt ] || openssl req -x509 -newkey rsa:2048 -nodes -days 30 -subj "/CN=secure.example.com" -keyout /home/candidate/certs/tls.key -out /home/candidate/certs/tls.crt >/dev/null 2>&1'
log "q60 seeded"
