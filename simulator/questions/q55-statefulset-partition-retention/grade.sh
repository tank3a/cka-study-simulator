#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=sts-upd
check_image_web2() { [ "$(kc k8s -n sts-upd get pod web-2 -o jsonpath='{.spec.containers[0].image}')" = "nginx:1.27-alpine" ]; }
check_jsonpath "updateStrategy RollingUpdate partition 2" 2 k8s sts/web -n $NS '{.spec.updateStrategy.rollingUpdate.partition}' "2"
check_eventually "web-2 runs the new image" 1 120 -- \
  check_image_web2
# only counts once the canary was rolled out (untouched state must not score)
check_sh "web-0 and web-1 keep nginx:1.27" 2 \
  '[ "$(kc k8s -n sts-upd get pod web-2 -o jsonpath="{.spec.containers[0].image}")" = nginx:1.27-alpine ] && [ "$(kc k8s -n sts-upd get pod web-0 web-1 -o jsonpath="{.items[*].spec.containers[0].image}")" = "nginx:1.27 nginx:1.27" ]'
check_jsonpath "retention whenDeleted Retain" 1 k8s sts/web -n $NS '{.spec.persistentVolumeClaimRetentionPolicy.whenDeleted}' "Retain"
check_jsonpath "retention whenScaled Delete" 1 k8s sts/web -n $NS '{.spec.persistentVolumeClaimRetentionPolicy.whenScaled}' "Delete"
