#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=sidecar-demo
check_eq "log-agent is an init container with restartPolicy Always" 3 "Always" -- \
  kc k8s -n $NS get deploy shipper -o jsonpath='{.spec.template.spec.initContainers[?(@.name=="log-agent")].restartPolicy}'
check_eq "log-agent image busybox:1.37" 1 "busybox:1.37" -- \
  kc k8s -n $NS get deploy shipper -o jsonpath='{.spec.template.spec.initContainers[?(@.name=="log-agent")].image}'
check_eq "log-agent limits cpu 50m memory 32Mi" 1 "50m 32Mi" -- \
  kc k8s -n $NS get deploy shipper -o jsonpath='{.spec.template.spec.initContainers[?(@.name=="log-agent")].resources.limits.cpu} {.spec.template.spec.initContainers[?(@.name=="log-agent")].resources.limits.memory}'
check_eq "container app still present" 1 "app" -- \
  kc k8s -n $NS get deploy shipper -o jsonpath='{.spec.template.spec.containers[*].name}'
check_eventually "all shipper Pods Ready" 2 120 -- \
  kc k8s -n $NS wait --for=condition=Available deploy/shipper --timeout=2s
check_eventually "sidecar can read the app log through the shared volume" 2 60 -- \
  kc k8s -n $NS exec deploy/shipper -c log-agent -- grep -q "request handled" /var/log/app/app.log
check_eventually "sidecar sees ConfigMap agent-config" 1 60 -- \
  kc k8s -n $NS exec deploy/shipper -c log-agent -- grep -q "destination=stdout" /etc/agent/agent.conf
check_eventually "sidecar logs show the app log lines" 1 60 -- \
  kc k8s -n $NS logs deploy/shipper -c log-agent --tail=20
check_eq "log-agent mounts logs read-only at /var/log/app" 1 "logs /var/log/app true" -- \
  kc k8s -n $NS get deploy shipper -o jsonpath='{.spec.template.spec.initContainers[?(@.name=="log-agent")].volumeMounts[0].name} {.spec.template.spec.initContainers[?(@.name=="log-agent")].volumeMounts[0].mountPath} {.spec.template.spec.initContainers[?(@.name=="log-agent")].volumeMounts[0].readOnly}'
