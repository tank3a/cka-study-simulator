You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The only Ingress controller that runs in this cluster is ingress-nginx; it watches IngressClasses whose `spec.controller` is `k8s.io/ingress-nginx`. Two IngressClasses exist (`kubectl get ingressclass`), and two Ingresses in the namespace are not picked up by the controller.

1. Write the name of the IngressClass that ingress-nginx handles into `/home/candidate/ing-class.txt`.
2. The Ingress `shop` points to the wrong IngressClass. Change it to the class from step 1.
3. The Ingress `legacy` still uses the deprecated annotation `kubernetes.io/ingress.class` and has no `spec.ingressClassName`. Migrate it: set `spec.ingressClassName` to the class from step 1 and remove the annotation.

Do not change the rules, hosts or backends of the Ingresses, and do not delete any IngressClass.
