#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=quota-b
Q() { kc k8s -n quota-b get resourcequota object-caps -o jsonpath="$1"; }
check_eq "quota Deployments 2, PVCs 2" 2 "2 2" -- \
  Q "{.spec.hard.count/deployments\\.apps} {.spec.hard.persistentvolumeclaims}"
check_eq "quota requests.storage 3Gi, services.nodeports 0" 2 "3Gi 0" -- \
  Q "{.spec.hard.requests\\.storage} {.spec.hard.services\\.nodeports}"
check_jsonpath "Deployment a-deploy-extra was admitted" 1 k8s deploy/a-deploy-extra -n $NS '{.metadata.name}' "a-deploy-extra"
# "rejected" checks only count once the quota exists and the directory was applied (untouched state must not score)
A='kc k8s -n quota-b get resourcequota object-caps >/dev/null 2>&1 && kc k8s -n quota-b get deploy a-deploy-extra >/dev/null 2>&1'
check_sh "Deployment b-deploy-third was rejected" 1 "$A"' && ! kc k8s -n quota-b get deploy b-deploy-third'
check_sh "NodePort Service was rejected" 1 "$A"' && ! kc k8s -n quota-b get svc np-svc'
check_sh "pvc-big (5Gi) was rejected" 1 "$A"' && ! kc k8s -n quota-b get pvc pvc-big'
check_jsonpath "pvc-small (1Gi) was admitted" 1 k8s pvc/pvc-small -n $NS '{.metadata.name}' "pvc-small"
check_file "stderr saved with quota errors" 1 term /home/candidate/quota-errors.txt 'exceeded quota: object-caps'
