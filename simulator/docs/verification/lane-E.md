# Lane E verification (q92-q100, q102; q101 not in this lane)

Scores are points passed / total. Each question was run: setup x2, grade untouched, solution applied as `candidate` in exam-term, grade, reset (delete namespaces / exam.q IngressClasses / home files), setup again, grade. Final state: each question is left in its freshly seeded state (setup applied, solution not applied).

| id | setup ok | idempotent | untouched | solution | reset ok | fixes made | status | note |
|---|---|---|---|---|---|---|---|---|
| q92-svc-loadbalancer-local | yes | yes | 1/10 (only "Deployment not modified") | 10/10 | yes (1/10) | none | VERIFIED | EXTERNAL-IP pending expected. Solution used `expose --dry-run` + yq for the two spec fields. |
| q93-svc-nodeport-to-loadbalancer | yes | yes | 0/9 (was 4/9) | 9/9 | yes (0/9) | grade.sh: nodePort/ports, same-UID and nodePort-30091 HTTP checks gated on type=LoadBalancer | VERIFIED | Untouched state satisfied 4 checks before the fix. |
| q94-headless-service-dns | yes | yes | 1/9 | 9/9 | yes (1/9) | none | VERIFIED | Endpoints need a few seconds after creating db-hl; A-record count was 3. |
| q95-externalname-service | yes | yes | 2/9 | 9/9 | yes (2/9) | solution.md: `kubectl create service externalname` sets selector app=<name> (violates "no selector"), so solution now uses YAML apply and notes the patch needed; grade.sh: "backend not modified" used metadata.generation, which Services do not have (always failed), now checks type/selector/port | VERIFIED | Both were real bugs (solution text and grader). |
| q96-kube-proxy-mode-rules | yes | yes | 1/9 | 9/9 | yes (1/9) | none | VERIFIED | Read-only iptables via `ssh -n k8s-node1`. mode=iptables (empty field), clusterCIDR 10.244.0.0/16. Untouched 1/9 is the "kube-proxy CM untouched" check. |
| q97-kube-proxy-session-affinity | yes | yes | 2/9 | 9/9 | yes (2/9) | none | VERIFIED | Untouched 2/9 = UID check + Deployment unmodified (both vacuously true). |
| q98-gateway-allowed-routes-namespaces | yes | yes | 1/11 | 11/11 | yes (1/11) | grade.sh: a.apps.example.com HTTP check is now check_eventually 40s (NGF data plane takes >3 s to program, immediate grade failed once); "b-route NOT accepted" gated on shared-gw existing (was passing untouched) | VERIFIED | Live via shared-gw-nginx NodePort. b-route stays Accepted=False. |
| q99-ingress-to-gateway-tls-exact | yes | yes | 1/11 | 11/11 | yes (1/11) | none | VERIFIED | Live HTTPS checks pass (/api -> api, /api/v2 -> web). The HTTP checks are not eventual: they failed if graded immediately after apply (I waited 20 s in my script); consider check_eventually if candidates complain. Ingress deleted by solution; setup does not resurrect it while Gateway/Route exist. |
| q100-ingress-default-backend-wildcard | yes | yes | 0/8 | 8/8 | yes (0/8) | none | VERIFIED-PARTIAL | Spec checks only (ingress-nginx not installed); live checks skipped by design. |
| q102-ingress-class-controller-match | yes | yes | 2/8 | 8/8 | yes (2/8) | none | VERIFIED-PARTIAL | Spec-only (no controller). Setup creates the IngressClasses fix-nginx/fix-haproxy (label exam.q); reset removed them with `delete ingressclass -l exam.q=<id>`. Untouched 2/8 = rules unchanged + classes exist. |

Notes: q96 first attempt scored 1/9 because my test script's `ssh` consumed the script from stdin (test artifact, not a question bug; fixed with `ssh -n`). A hand-made `legacy-db` Service from my debugging contaminated one q95 run; the final q95 run was clean.
