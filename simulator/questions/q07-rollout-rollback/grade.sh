#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=rollout-demo
check_jsonpath "image is nginx:1.27-alpine" 1 k8s deploy/web -n $NS '{.spec.template.spec.containers[0].image}' "nginx:1.27-alpine"
check_jsonpath "strategy type RollingUpdate" 1 k8s deploy/web -n $NS '{.spec.strategy.type}' "RollingUpdate"
check_jsonpath "maxSurge is 2" 1 k8s deploy/web -n $NS '{.spec.strategy.rollingUpdate.maxSurge}' "2"
check_jsonpath "maxUnavailable is 0" 1 k8s deploy/web -n $NS '{.spec.strategy.rollingUpdate.maxUnavailable}' "0"
check_eventually "all 4 replicas updated and available" 2 90 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.availableReplicas}'=4 deploy/web --timeout=2s
check_sh "rollback happened (a revision 3 ReplicaSet with nginx:1.27 exists)" 2 \
  'kc k8s -n rollout-demo get rs -o jsonpath="{range .items[*]}{.metadata.annotations.deployment\.kubernetes\.io/revision} {.spec.template.spec.containers[0].image}{\"\n\"}{end}" | grep -qE "^3 nginx:1.27$"'
check_sh "change-cause annotation recorded on current revision" 1 \
  'kc k8s -n rollout-demo get deploy web -o jsonpath="{.metadata.annotations.kubernetes\.io/change-cause}" | grep -q "upgrade to alpine"'
check_file "history file saved with change-cause" 1 term /home/candidate/web-history.txt 'upgrade to alpine'
