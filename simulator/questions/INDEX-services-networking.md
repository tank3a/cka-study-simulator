# Index: Services & Networking questions (q27-q36)

Domain weight on the real exam: Services & Networking 20%. Context for all: `k8s`. Weights here are the suggested per-task weights in a mock set.
Gateway tasks assume GatewayClass `nginx` (NGINX Gateway Fabric) and a NodePort data-plane Service created by the controller in the Gateway's namespace.

| id | title | concept | sub-competency | weight | difficulty | fidelity | doc link |
|---|---|---|---|---|---|---|---|
| q27-svc-nodeport-expose | NodePort + ClusterIP Services for a Deployment | Services | Use ClusterIP, NodePort, LoadBalancer types and endpoints | 5 | easy | high | https://kubernetes.io/docs/concepts/services-networking/service/ |
| q28-svc-selector-endpoints-debug | Service has no endpoints (selector + targetPort, EndpointSlice IPs to file) | Services / troubleshooting | Troubleshoot services and networking; endpoints | 6 | medium | high | https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/ |
| q29-netpol-pick-least-permissive | Pick the least permissive of three NetworkPolicy YAMLs | NetworkPolicy | Define and enforce Network Policies | 7 | medium | high (needs working NetPol enforcement) | https://kubernetes.io/docs/concepts/services-networking/network-policies/ |
| q30-netpol-egress-dns | Write an egress NetworkPolicy incl. DNS | NetworkPolicy | Define and enforce Network Policies | 7 | hard | high (needs working NetPol enforcement) | https://kubernetes.io/docs/concepts/services-networking/network-policies/ |
| q31-gateway-httproute-routing | HTTPRoute with path prefixes and header match | Gateway API | Use the Gateway API to manage Ingress traffic | 7 | medium | high | https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/ |
| q32-gateway-tls-listener | Gateway HTTPS listener (TLS terminate) + HTTP->HTTPS redirect | Gateway API (TLS) | Use the Gateway API to manage Ingress traffic | 8 | hard | high | https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/ |
| q33-ingress-to-gateway-migrate | Migrate an Ingress to an HTTPRoute, delete the Ingress | Ingress + Gateway API | Gateway API; know how to use Ingress resources | 6 | medium | high (Ingress is only read as an object) | https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/ |
| q34-ingress-tls-paths | Create an Ingress with two paths and TLS (optional) | Ingress | Know how to use Ingress controllers and resources | 4 | medium | partial/low (ingress-nginx retired; live check only if addon present) | https://kubernetes.io/docs/concepts/services-networking/ingress/ |
| q35-coredns-forward-rewrite | CoreDNS Corefile: zone forward + name rewrite (edits kube-system, cleanup.sh restores) | CoreDNS | Understand and use CoreDNS | 7 | hard | high | https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/ |
| q36-dns-pod-network-debug | Pod DNS failure (dnsPolicy None) + podCIDR / CNI conf / kube-dns IP facts | CoreDNS + pod connectivity/CNI | Understand and use CoreDNS; connectivity between Pods; CNI | 6 | medium | high (CNI is kindnet, file names differ from Calico/Cilium) | https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/ |

Coverage notes
- Services: q27, q28. NetworkPolicy: q29, q30. Gateway API: q31, q32, q33. Ingress: q33 (read/migrate), q34 (create, optional).
- CoreDNS: q35 (config), q36 part 1 (debugging). Pod connectivity/CNI: q36 part 2 (inventory), q28 and q29/q30 (connectivity behavior); a full CNI install lives in the ik8s Calico task, not here.
- LoadBalancer type is not given its own task (kind has no LB; EXTERNAL-IP stays pending); it is covered only in the solution notes of q27.
- Sum of weights q27-q36 = 63; pick a subset (about 20% of a set) for a mock exam.
