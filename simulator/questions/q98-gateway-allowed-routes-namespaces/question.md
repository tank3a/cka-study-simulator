You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The platform team runs one shared Gateway for several teams. The GatewayClass is named `nginx`.
Team A (namespace `gw-team-a`) has a Service `app-a` (port 80). Team B (namespace `gw-team-b`) has a Service `app-b` (port 80) and an HTTPRoute `b-route` for host `b.apps.example.com`, which already references the Gateway you are going to create.

1. Write the `controllerName` of the GatewayClass `nginx` into `/home/candidate/gwc-controller.txt`.
2. Create a Gateway named `shared-gw` in namespace `gw-multi` with one listener:
   - name `http`, port `80`, protocol `HTTP`, hostname `*.apps.example.com`.
   - Routes may attach **only from namespaces that carry the label `shared-gw-access=true`** (not from every namespace).
3. Give team A access: label the namespace `gw-team-a` with `shared-gw-access=true`.
4. In namespace `gw-team-a` create an HTTPRoute named `a-route` for host `a.apps.example.com` that sends all traffic to Service `app-a` port 80 through `shared-gw`.

Team B has **not** been granted access: do not label `gw-team-b`; its route must stay unaccepted.
