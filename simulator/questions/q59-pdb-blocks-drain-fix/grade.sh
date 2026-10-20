#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=pdb-b
check_jsonpath "maxUnavailable 1" 2 k8s pdb/critical-pdb -n $NS '{.spec.maxUnavailable}' "1"
check_eq "minAvailable removed" 1 "" -- kc k8s -n $NS get pdb critical-pdb -o jsonpath='{.spec.minAvailable}'
check_jsonpath "unhealthyPodEvictionPolicy AlwaysAllow" 1 k8s pdb/critical-pdb -n $NS '{.spec.unhealthyPodEvictionPolicy}' "AlwaysAllow"
check_eventually "PDB reports 1 allowed disruption" 1 60 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.disruptionsAllowed}'=1 pdb/critical-pdb --timeout=2s
check_jsonpath "selector unchanged, Deployment still 2 replicas" 1 k8s deploy/critical -n $NS '{.spec.replicas}' "2"
