set -uo pipefail
source "$LIB/common.sh"
ns_create k8s crd-demo
ns_create k8s crd-other
for k in backups:Backup:backup restores:Restore:restore; do
  plural=${k%%:*}; rest=${k#*:}; kind=${rest%%:*}; singular=${rest#*:}
  kapply k8s -f - <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: ${plural}.ops.cka.example.com
  labels: {exam.q: "$QID"}
spec:
  group: ops.cka.example.com
  scope: Namespaced
  names: {plural: ${plural}, singular: ${singular}, kind: ${kind}, shortNames: [${singular:0:2}]}
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required: [schedule, target]
              properties:
                schedule: {type: string, description: "Cron expression of the ${kind}"}
                target: {type: string, description: "Object to process, for example pvc/data"}
                retentionDays:
                  type: integer
                  minimum: 1
                  maximum: 30
                  description: "RetentionDays is the number of days a result is kept before it is deleted"
YAML
done
kapply k8s -f - <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: tickets.help.cka.example.com
  labels: {exam.q: "$QID"}
spec:
  group: help.cka.example.com
  scope: Namespaced
  names: {plural: tickets, singular: ticket, kind: Ticket}
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          x-kubernetes-preserve-unknown-fields: true
YAML
wait_for 60 -- kc k8s wait --for=condition=Established crd/backups.ops.cka.example.com crd/restores.ops.cka.example.com crd/tickets.help.cka.example.com --timeout=2s
for ns in crd-demo crd-other; do
  for n in seed-a seed-b; do
    [ "$ns" = crd-demo ] && [ "$n" = seed-b ] && continue
    kapply k8s -f - <<YAML
apiVersion: ops.cka.example.com/v1
kind: Backup
metadata: {name: $n, namespace: $ns}
spec: {schedule: "0 5 * * *", target: "pvc/seed", retentionDays: 3}
YAML
  done
done
term_sh 'mkdir -p /home/candidate/answers && rm -f /home/candidate/answers/q25-*.txt'
