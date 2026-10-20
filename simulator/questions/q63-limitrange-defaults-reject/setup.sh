#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s lr-demo
term_put /home/candidate/lr-plain.yaml <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: plain
  labels: {exam.q: "$QID"}
spec:
  containers:
  - name: app
    image: busybox:1.37
    command: ["sleep", "3600"]
YAML
term_put /home/candidate/lr-toobig.yaml <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: toobig
  labels: {exam.q: "$QID"}
spec:
  containers:
  - name: app
    image: busybox:1.37
    command: ["sleep", "3600"]
    resources:
      requests: {cpu: "2"}
      limits: {cpu: "2"}
YAML
log "q63 seeded"
