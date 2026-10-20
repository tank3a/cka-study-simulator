#!/usr/bin/env bash
# CKA simulator grading helpers. See docs/HELPERS.md. Emits JSONL on stdout, human text on stderr.
_ASSERT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_ASSERT_DIR/common.sh"

_json_str() { printf '%s' "$1" | head -c 400 | tr '\n\r\t' '   ' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr -d '\000-\037'; }
_emit() { # desc pts pass detail
  local pass=false mark="FAIL"; [ "$3" = 1 ] && { pass=true; mark="PASS"; }
  printf '{"q":"%s","check":"%s","points":%s,"pass":%s,"detail":"%s"}\n' \
    "${QID:-?}" "$(_json_str "$1")" "$2" "$pass" "$(_json_str "$4")"
  printf '  [%s] %s (%s pt)\n' "$mark" "$1" "$2" >&2
}
_isnum() { case "$1" in ''|*[!0-9]*) return 1;; *) return 0;; esac; }
# sets _D _P and leaves rest in "$@" via _SHIFT count
_pre() { _D=$1; _P=1; _SHIFT=1; if _isnum "${2:-}" && [ "${3:-}" != "--" ]; then _P=$2; _SHIFT=2; fi; }
_pre_cmd() { _D=$1; _P=1; _SHIFT=1; if _isnum "${2:-}"; then _P=$2; _SHIFT=2; fi; }
_run() { _OUT=$("$@" 2>&1); _RC=$?; }

check() { _pre_cmd "$@"; shift $_SHIFT; [ "${1:-}" = "--" ] && shift
  _run "$@"; if [ $_RC -eq 0 ]; then _emit "$_D" $_P 1 "$_OUT"; else _emit "$_D" $_P 0 "rc=$_RC $_OUT"; fi; }
check_sh() { _pre_cmd "$@"; shift $_SHIFT; local s=$1; _OUT=$( (eval "$s") 2>&1 ); _RC=$?
  if [ $_RC -eq 0 ]; then _emit "$_D" $_P 1 "$_OUT"; else _emit "$_D" $_P 0 "rc=$_RC $_OUT"; fi; }
check_eq() { _pre "$@"; shift $_SHIFT; local exp=$1; shift; [ "${1:-}" = "--" ] && shift
  _OUT=$("$@" 2>/dev/null); _OUT=$(printf '%s' "$_OUT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if [ "$_OUT" = "$exp" ]; then _emit "$_D" $_P 1 "got '$_OUT'"; else _emit "$_D" $_P 0 "expected '$exp' got '$_OUT'"; fi; }
check_match() { _pre "$@"; shift $_SHIFT; local re=$1; shift; [ "${1:-}" = "--" ] && shift
  _OUT=$("$@" 2>&1)
  if printf '%s' "$_OUT" | grep -Eq -- "$re"; then _emit "$_D" $_P 1 "matched /$re/"; else _emit "$_D" $_P 0 "no match /$re/ in: $_OUT"; fi; }
check_jsonpath() { _D=$1; shift; _P=1; if _isnum "$1"; then _P=$1; shift; fi
  local c=$1 obj=$2; shift 2; local ns=(); if [ "$1" = "-n" ]; then ns=(-n "$2"); shift 2; fi
  local jp=$1 exp=$2
  _OUT=$(kc "$c" ${ns[@]+"${ns[@]}"} get "$obj" -o "jsonpath=$jp" 2>&1)
  if [ "$_OUT" = "$exp" ]; then _emit "$_D" $_P 1 "got '$_OUT'"; else _emit "$_D" $_P 0 "expected '$exp' got '$_OUT'"; fi; }
check_node_cmd() { _pre_cmd "$@"; shift $_SHIFT; local n=$1; shift; [ "${1:-}" = "--" ] && shift
  _run on_node "$n" "$@"; if [ $_RC -eq 0 ]; then _emit "$_D" $_P 1 "$_OUT"; else _emit "$_D" $_P 0 "rc=$_RC $_OUT"; fi; }
check_node_sh() { _pre_cmd "$@"; shift $_SHIFT; local n=$1 s=$2
  _run node_sh "$n" "$s"; if [ $_RC -eq 0 ]; then _emit "$_D" $_P 1 "$_OUT"; else _emit "$_D" $_P 0 "rc=$_RC $_OUT"; fi; }
check_file() { _pre_cmd "$@"; shift $_SHIFT; local where=$1 path=$2 re=${3:-}
  if [ "$where" = term ]; then _OUT=$(term_sh "cat '$path'" 2>&1); _RC=$?; else _OUT=$(node_get "$where" "$path" 2>&1); _RC=$?; fi
  if [ $_RC -ne 0 ]; then _emit "$_D" $_P 0 "missing $path"; return; fi
  if [ -z "$re" ] || printf '%s' "$_OUT" | grep -Eq -- "$re"; then _emit "$_D" $_P 1 "ok $path"; else _emit "$_D" $_P 0 "$path does not match /$re/"; fi; }
check_eventually() { _pre_cmd "$@"; shift $_SHIFT; local t=$1; shift; [ "${1:-}" = "--" ] && shift
  local end=$(( $(date +%s) + t ))
  while :; do _run "$@"; [ $_RC -eq 0 ] && { _emit "$_D" $_P 1 "$_OUT"; return; }
    [ "$(date +%s)" -ge "$end" ] && { _emit "$_D" $_P 0 "timeout ${t}s: $_OUT"; return; }; sleep 2; done; }
_curl_term() { local s="" a; for a in "$@"; do s="$s $(printf '%q' "$a")"; done; term_sh "curl -s --max-time 5 $s" ; }
check_http() { _pre "$@"; shift $_SHIFT; local want=$1; shift
  local s="" a; for a in "$@"; do s="$s $(printf '%q' "$a")"; done
  _OUT=$(term_sh "curl -s -o /dev/null -w '%{http_code}' --max-time 5 $s" 2>&1)
  if [ "$_OUT" = "$want" ]; then _emit "$_D" $_P 1 "status $_OUT"; else _emit "$_D" $_P 0 "expected $want got $_OUT"; fi; }
check_http_body() { _pre "$@"; shift $_SHIFT; local re=$1; shift
  _OUT=$(_curl_term "$@" 2>&1)
  if printf '%s' "$_OUT" | grep -Eq -- "$re"; then _emit "$_D" $_P 1 "body matched"; else _emit "$_D" $_P 0 "body did not match /$re/: $_OUT"; fi; }
