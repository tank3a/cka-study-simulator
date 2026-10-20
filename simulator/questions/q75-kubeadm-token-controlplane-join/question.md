Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

A second **control plane** node will be added to this cluster.

1. Create a bootstrap token with the exact ID `0a1b2c.0123456789abcdef`, a lifetime of 45 minutes and the description `second control plane`.
2. Upload the control plane certificates to the cluster (encrypted with a certificate key) so that another control plane node can download them.
3. Save the complete `kubeadm join` command for the new **control plane** node to `/opt/cka/cp-join.txt`. It must contain the token, the CA certificate hash, `--control-plane` and the certificate key.

Constraints:
- Do not renew or change any certificate.
- Do not use the token `abcdef.0123456789abcdef` if it exists.
