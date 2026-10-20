#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=cfg-demo
check_jsonpath "ConfigMap api-config LOG_LEVEL=debug" 1 k8s cm/api-config -n $NS '{.data.LOG_LEVEL}' "debug"
check_sh "ConfigMap has app.properties with file content" 1 \
  'kc k8s -n cfg-demo get cm api-config -o jsonpath="{.data.app\.properties}" | grep -q "feature.beta=true"'
check_sh "Secret api-secret has username and password" 1 \
  '[ "$(kc k8s -n cfg-demo get secret api-secret -o jsonpath="{.data.username}" | base64 -d)" = "admin" ] && [ "$(kc k8s -n cfg-demo get secret api-secret -o jsonpath="{.data.password}" | base64 -d)" = "S3cr3tPass" ]'
check_jsonpath "Secret type Opaque" 1 k8s secret/api-secret -n $NS '{.type}' "Opaque"
check_eq "Deployment env references (cm LOG_LEVEL, secret password)" 2 "api-config/LOG_LEVEL api-secret/password" -- \
  kc k8s -n $NS get deploy api -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="LOG_LEVEL")].valueFrom.configMapKeyRef.name}/{.spec.template.spec.containers[0].env[?(@.name=="LOG_LEVEL")].valueFrom.configMapKeyRef.key} {.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.name}/{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.key}'
check_eventually "pod sees LOG_LEVEL=debug" 1 90 -- \
  kc k8s -n $NS exec deploy/api -- sh -c '[ "$LOG_LEVEL" = debug ] && [ "$DB_PASSWORD" = S3cr3tPass ]'
check_eventually "pod sees /etc/api/app.properties" 1 60 -- \
  kc k8s -n $NS exec deploy/api -- grep -q "feature.beta=true" /etc/api/app.properties
check_eventually "pod sees secret files in /etc/secrets" 1 60 -- \
  kc k8s -n $NS exec deploy/api -- sh -c '[ "$(cat /etc/secrets/username)" = admin ]'
check_eq "secret volume defaultMode 0400 (256)" 1 "256" -- \
  kc k8s -n $NS get deploy api -o jsonpath='{.spec.template.spec.volumes[*].secret.defaultMode}'
