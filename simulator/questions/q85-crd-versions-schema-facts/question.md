Context: `kubectl config use-context {{context}}`

The CustomResourceDefinition for `Widget` (API group `shop.cka.example.com`) is installed. Widgets exist in namespaces `widget-lab` and `widget-other`.

1. Write the following facts, one `key=value` per line, to `/home/candidate/answers/q85.txt` (versions as a comma-separated, alphabetically sorted list without spaces):
   ```
   scope=<Namespaced|Cluster>
   storage_version=<version the objects are stored in>
   served_versions=<all versions the API server serves>
   short_name=<the short name of the resource>
   required_fields=<required fields under spec in the newest version, comma-separated>
   red_widgets=<namespace/name of every Widget with spec.color red in all namespaces, sorted, comma-separated>
   ```
2. Create a Widget `w5` in namespace `{{namespace}}` with color `green` and size `M`, using the **storage version**.
3. The manifest `/home/candidate/crd/widget-broken.yaml` is rejected by the API server. Correct it so it follows the schema (keep the name `w6` and the color green; use the largest size that the schema allows) and apply it.

Constraints:
- Do not edit or delete the CRD.
