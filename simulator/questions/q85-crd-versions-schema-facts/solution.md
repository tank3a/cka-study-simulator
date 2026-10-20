# q85 풀이

```bash
kubectl config use-context k8s
kubectl get crd widgets.shop.cka.example.com -o yaml | less
kubectl get crd widgets.shop.cka.example.com -o jsonpath='{.spec.scope}{"\n"}{.spec.names.shortNames}{"\n"}'
kubectl get crd widgets.shop.cka.example.com -o jsonpath='{range .spec.versions[*]}{.name} served={.served} storage={.storage}{"\n"}{end}'
kubectl explain widget.spec --api-version=shop.cka.example.com/v1     # required: size
kubectl get widgets -A -o jsonpath='{range .items[?(@.spec.color=="red")]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}' | sort

cat > ~/answers/q85.txt <<EOF
scope=Namespaced
storage_version=v1
served_versions=v1,v1alpha1
short_name=wg
required_fields=size
red_widgets=widget-lab/w1,widget-lab/w3,widget-other/w4
EOF

# w5
cat <<EOF | kubectl apply -f -
apiVersion: shop.cka.example.com/v1
kind: Widget
metadata: {name: w5, namespace: widget-lab}
spec: {color: green, size: M}
EOF

# w6: 오류 메시지를 읽고 수정 (colour -> color, XL -> L)
kubectl apply -f ~/crd/widget-broken.yaml        # unknown field "spec.colour", Unsupported value: "XL"
sed -i 's/colour/color/; s/XL/L/' ~/crd/widget-broken.yaml
kubectl apply -f ~/crd/widget-broken.yaml
```

핵심: 한 CRD에 버전이 여러 개일 수 있고 `storage: true`인 버전은 하나뿐이다. 오브젝트 생성에는 서빙되는 최신 버전을 쓰되 스키마(필수 필드, enum, 알 수 없는 필드 거부)는 버전마다 다르다. `kubectl explain <kind>.spec --api-version=<group>/<version>`으로 버전별 스키마를 본다.

문서: https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/
