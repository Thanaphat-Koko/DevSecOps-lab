# Ref : https://metallb.io/installation/

#!/bin/bash
set -e

helm repo add metallb https://metallb.github.io/metallb

helm repo update

cat <<EOF | sudo tee metallb-values.yaml
controller:
  enabled: true
  # -- log level. Must be one of: all, debug, info, warn, error or none
  logLevel: warn
speaker:
  enabled: true
  logLevel: warn
  frr:
    enabled: false
frrk8s:
  enabled: false
EOF

helm upgrade --install metallb metallb/metallb  \
    --namespace metallb \
    --create-namespace \
    -f metallb-values.yaml


cat <<EOF | sudo tee metallb-config.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb
spec:
    # LoadBalancer IP range ต้องเป็น IP ที่ไม่ได้ใช้งาน และอยู่ในวง LAN เดียวกัน
  addresses:
  - 172.26.46.174-172.26.46.179 
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2advertisement1
  namespace: metallb
spec:
  ipAddressPools:
  - default
EOF

kubectl -n metallb apply -f metallb-config.yaml