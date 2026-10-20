#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=secret-demo
check_jsonpath "web-tls is type kubernetes.io/tls" 1 k8s secret/web-tls -n $NS '{.type}' "kubernetes.io/tls"
check_sh "web-tls holds a certificate" 1 'kc k8s -n secret-demo get secret web-tls -o jsonpath="{.data.tls\.crt}" | base64 -d | grep -q "BEGIN CERTIFICATE"'
check_jsonpath "regcred is type dockerconfigjson" 1 k8s secret/regcred -n $NS '{.type}' "kubernetes.io/dockerconfigjson"
check_sh "regcred has server, user and password" 1 \
  'j=$(kc k8s -n secret-demo get secret regcred -o jsonpath="{.data.\.dockerconfigjson}" | base64 -d); echo "$j" | grep -q registry.example.com && echo "$j" | grep -q ci-bot && echo "$j" | grep -q "Pa55w0rd!"'
check_jsonpath "app-sa uses regcred as imagePullSecret" 1 k8s sa/app-sa -n $NS '{.imagePullSecrets[0].name}' "regcred"
check_sh "api-token token=abc123" 1 '[ "$(kc k8s -n secret-demo get secret api-token -o jsonpath="{.data.token}" | base64 -d)" = abc123 ]'
check_eq "tls volume defaultMode 0440 (288), read-only at /etc/tls" 2 "288 /etc/tls true" -- \
  kc k8s -n $NS get pod secure-app -o jsonpath='{.spec.volumes[?(@.secret.secretName=="web-tls")].secret.defaultMode} {.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/tls")].mountPath} {.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/tls")].readOnly}'
check_eq "API_TOKEN from secretKeyRef api-token/token" 1 "api-token/token" -- \
  kc k8s -n $NS get pod secure-app -o jsonpath='{.spec.containers[0].env[?(@.name=="API_TOKEN")].valueFrom.secretKeyRef.name}/{.spec.containers[0].env[?(@.name=="API_TOKEN")].valueFrom.secretKeyRef.key}'
check_eventually "Pod Running and sees token and cert" 1 90 -- \
  kc k8s -n $NS exec secure-app -- sh -c '[ "$API_TOKEN" = abc123 ] && grep -q "BEGIN CERTIFICATE" /etc/tls/tls.crt'
