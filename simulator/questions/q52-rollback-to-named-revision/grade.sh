#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=rollout2
check_jsonpath "Deployment image is the v2-stable one (nginx:1.26)" 3 k8s deploy/shop -n $NS '{.spec.template.spec.containers[0].image}' "nginx:1.26"
check_eventually "rollout complete, replicas available" 2 120 -- kc k8s -n $NS rollout status deploy/shop --timeout=2s
check_jsonpath "change-cause annotation updated" 1 k8s deploy/shop -n $NS '{.metadata.annotations.kubernetes\.io/change-cause}' "rollback to v2-stable"
check_file "history saved before rollback (still shows v4-broken as latest)" 1 term /home/candidate/history-before.txt 'v4-broken'
check_sh "history file contains all four causes" 1 \
  'f=$(term_sh "cat /home/candidate/history-before.txt" 2>/dev/null); for c in v1-initial v2-stable v3-experimental v4-broken; do echo "$f" | grep -q "$c" || exit 1; done'
