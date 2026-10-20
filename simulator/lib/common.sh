#!/usr/bin/env bash
# CKA simulator shared helpers (host side). See docs/HELPERS.md. bash 3.2 compatible.
[ -n "${_SIM_COMMON:-}" ] && return 0
_SIM_COMMON=1
: "${SIM_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
: "${LIB:=$SIM_ROOT/lib}"
: "${ADMIN_KUBECONFIG:=$SIM_ROOT/state/admin.kubeconfig}"
: "${TERM_CONTAINER:=exam-term}"
export SIM_ROOT LIB ADMIN_KUBECONFIG

log() { echo "$*" >&2; }

resolve_node() {
  case "$1" in
    k8s-cp) echo k8s-control-plane;;   k8s-node1) echo k8s-worker;;  k8s-node2) echo k8s-worker2;;
    ek8s-cp) echo ek8s-control-plane;; ek8s-node1) echo ek8s-worker;;
    ik8s-cp) echo ik8s-control-plane;; ik8s-node1) echo ik8s-worker;;
    *) echo "$1";;
  esac
}

kc() { local c=$1; shift; kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context "$c" "$@"; }
kapply() { local c=$1; shift; if [ $# -eq 0 ]; then set -- -f -; fi; kc "$c" apply "$@"; }

ns_create() {
  # a namespace still Terminating (cleanup uses --wait=false) would swallow the seeded objects: wait for it to go away
  local _i; for _i in $(seq 1 45); do [ "$(kc "$1" get namespace "$2" -o jsonpath='{.status.phase}' 2>/dev/null)" = Terminating ] || break; sleep 2; done
  kc "$1" create namespace "$2" --dry-run=client -o yaml | kc "$1" apply -f - >/dev/null &&
  kc "$1" label namespace "$2" "exam.q=${QID:-unknown}" --overwrite >/dev/null
}
label_q() { local c=$1 k=$2 n=$3; shift 3; kc "$c" label "$k" "$n" "$@" "exam.q=${QID:-unknown}" --overwrite >/dev/null; }

on_node() {
  local n; n=$(resolve_node "$1"); shift
  local s="" a; for a in "$@"; do s="$s $(printf '%q' "$a")"; done
  docker exec -i "$n" bash -lc "$s"
}
node_sh() {
  local n; n=$(resolve_node "$1"); shift
  if [ $# -gt 0 ]; then docker exec -i "$n" bash -lc "$1"; else docker exec -i "$n" bash -l; fi
}
node_put() {
  local n; n=$(resolve_node "$1"); local p=$2 m=${3:-644}
  docker exec -i "$n" bash -c "mkdir -p \"\$(dirname '$p')\" && cat > '$p' && chmod $m '$p'"
}
node_get() { local n; n=$(resolve_node "$1"); docker exec "$n" cat "$2"; }
term_sh() { docker exec -i -u candidate -w /home/candidate "$TERM_CONTAINER" bash -lc "$1"; }
term_put() {
  local p=$1 m=${2:-644}
  docker exec -i -u candidate -w /home/candidate "$TERM_CONTAINER" bash -c "mkdir -p \"\$(dirname '$p')\" && cat > '$p' && chmod $m '$p'"
}
node_ip() {
  local n; n=$(resolve_node "$1")
  docker inspect -f '{{ (index .NetworkSettings.Networks "kind").IPAddress }}' "$n"
}
wait_for() {
  local t=$1; shift; [ "${1:-}" = "--" ] && shift
  local end=$(( $(date +%s) + t ))
  while :; do
    "$@" >/dev/null 2>&1 && return 0
    [ "$(date +%s)" -ge "$end" ] && return 1
    sleep 2
  done
}
wait_ready() {
  local c=$1 obj=$2; shift 2; local ns=() t=120
  while [ $# -gt 0 ]; do case "$1" in -n) ns=(-n "$2"); shift 2;; *) t=$1; shift;; esac; done
  case "$obj" in
    deploy*|deployment*|sts*|statefulset*|ds/*|daemonset*) kc "$c" ${ns[@]+"${ns[@]}"} rollout status "$obj" --timeout="${t}s" >/dev/null;;
    *) kc "$c" ${ns[@]+"${ns[@]}"} wait --for=condition=Ready "$obj" --timeout="${t}s" >/dev/null;;
  esac
}

# NodePort of a service (first port) in a cluster: svc_nodeport <ctx> <ns> <svc> [port-index]
svc_nodeport() { kc "$1" -n "$2" get svc "$3" -o "jsonpath={.spec.ports[${4:-0}].nodePort}"; }
