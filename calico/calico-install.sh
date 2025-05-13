# https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises

#!/bin/bash
set -e

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/operator-crds.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/tigera-operator.yaml

curl https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/custom-resources.yaml -O

cat << EOF | sudo tee custom-resources.yaml
# This section includes base Calico installation configuration.
# For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: 10.244.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()

---

# This section configures the Calico API server.
# For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}

---

# Configures the Calico Goldmane flow aggregator.
apiVersion: operator.tigera.io/v1
kind: Goldmane
metadata:
  name: default

---

# Configures the Calico Whisker observability UI.
apiVersion: operator.tigera.io/v1
kind: Whisker
metadata:
  name: default

EOF

kubectl create -f custom-resources.yaml