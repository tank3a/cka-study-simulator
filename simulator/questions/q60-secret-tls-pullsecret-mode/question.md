Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The terminal host holds a certificate and key in `/home/candidate/certs/tls.crt` and `/home/candidate/certs/tls.key`.
The ServiceAccount `app-sa` already exists in namespace `{{namespace}}`.

1. Create a TLS Secret `web-tls` from these two files.
2. Create a docker-registry Secret `regcred` for server `registry.example.com`, username `ci-bot`, password `Pa55w0rd!`, email `ci@example.com`,
   and make the ServiceAccount `app-sa` use it as an image pull secret.
3. Create a generic Secret `api-token` with key `token` and value `abc123`.
4. Create a Pod `secure-app` (image `nginx:1.27`, container name `app`, ServiceAccount `app-sa`) that:
   - mounts `web-tls` read-only at `/etc/tls` with file mode `0440`
   - exposes the key `token` of `api-token` as environment variable `API_TOKEN`

The Pod must be Running.
