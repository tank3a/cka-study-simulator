Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

A new worker node will join this cluster tomorrow.

1. Save the output of the kubeadm command that shows the expiration of all cluster certificates to `/opt/cka/cert-expiry.txt`.
2. Create a new bootstrap token with a TTL of 2 hours and the description `cka worker join`.
   Save the complete `kubeadm join ...` command for this token to `/opt/cka/join-command.txt`.
3. The old token `abcdef.0123456789abcdef` must not be usable anymore: delete it.
4. Using `openssl`, write the Subject Alternative Names of the API server certificate (`/etc/kubernetes/pki/apiserver.crt`) to `/opt/cka/apiserver-sans.txt`.

Constraints:
- Do not renew or change any certificate.
- The join command must contain the CA cert hash, as printed by kubeadm.
