#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=pdb-a
check_jsonpath "PDB minAvailable 75%" 2 k8s pdb/api-pdb -n $NS '{.spec.minAvailable}' "75%"
check_jsonpath "PDB selector app=api" 1 k8s pdb/api-pdb -n $NS '{.spec.selector.matchLabels.app}' "api"
check_eventually "PDB reports 1 allowed disruption" 1 60 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.disruptionsAllowed}'=1 pdb/api-pdb --timeout=2s
check_file "allowed disruptions written" 1 term /home/candidate/q58.txt '^[[:space:]]*1[[:space:]]*$'
check_jsonpath "Deployment untouched (4 replicas)" 1 k8s deploy/api -n $NS '{.spec.replicas}' "4"
