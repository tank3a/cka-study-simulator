You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The application in namespace `xn-lab` still connects to a database host called `legacy-db`. The database has been moved: the Service `backend` in namespace `xn-shared` (port 80) now provides it. The application Pod `tester` in `xn-lab` can be used for tests.

1. In namespace `xn-lab`, create a Service named `legacy-db` of type `ExternalName` that makes the name `legacy-db` an alias for the Service `backend` in namespace `xn-shared` (use its fully qualified cluster DNS name). The Service must not use a selector.
2. Create a second ExternalName Service named `cdn` in `xn-lab` that points to the external host `assets.example.org`.

Afterwards `wget -qO- http://legacy-db` inside Pod `tester` must return the backend page.
