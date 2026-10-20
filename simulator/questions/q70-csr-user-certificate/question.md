Context: `kubectl config use-context {{context}}`

A new developer, `dana`, needs a client certificate for this cluster. Work in the directory `/home/candidate/csr` (it exists).

1. With `openssl`, create the private key `dana.key` and a certificate request `dana.csr` with the subject `CN=dana` and organization `O=devs`.
2. Create a Kubernetes `CertificateSigningRequest` named `dana` from `dana.csr`: signer `kubernetes.io/kube-apiserver-client`, usage `client auth`, valid for one day (86400 seconds). Approve it.
3. Save the issued certificate to `/home/candidate/csr/dana.crt`.
4. Give `dana` read-only access in namespace `{{namespace}}` with a RoleBinding named `dana-view` that uses the ClusterRole `view`.

Constraints:
- Do not give `dana` any access outside `{{namespace}}`.
- The certificate must belong to the key you created.
