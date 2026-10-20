#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=sts-demo
check_jsonpath "Service kv is headless" 1 k8s svc/kv -n $NS '{.spec.clusterIP}' "None"
check_jsonpath "StatefulSet serviceName kv" 1 k8s sts/kv -n $NS '{.spec.serviceName}' "kv"
check_jsonpath "podManagementPolicy Parallel" 1 k8s sts/kv -n $NS '{.spec.podManagementPolicy}' "Parallel"
check_eq "volumeClaimTemplate data 1Gi RWO mounted at /data" 1 "data 1Gi ReadWriteOnce /data" -- \
  kc k8s -n $NS get sts kv -o jsonpath='{.spec.volumeClaimTemplates[0].metadata.name} {.spec.volumeClaimTemplates[0].spec.resources.requests.storage} {.spec.volumeClaimTemplates[0].spec.accessModes[0]} {.spec.template.spec.containers[0].volumeMounts[0].mountPath}'
check_eventually "2 replicas ready" 1 150 -- kc k8s -n $NS wait --for=jsonpath='{.status.readyReplicas}'=2 sts/kv --timeout=2s
check_eq "PVCs data-kv-0 and data-kv-1 are Bound" 2 "Bound Bound" -- \
  kc k8s -n $NS get pvc data-kv-0 data-kv-1 -o jsonpath='{.items[*].status.phase}'
check_eventually "kv-1 resolves via stable DNS name" 1 60 -- \
  kc k8s -n $NS exec dns-probe -- nslookup kv-1.kv.sts-demo.svc.cluster.local
