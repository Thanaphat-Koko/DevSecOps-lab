#!/bin/bash
set -e

# 1. Apply Calico CNI
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/tigera-operator.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/custom-resources.yaml

# 2. รอ Calico pod ขึ้นครบ
# echo "⏳ กำลังรอ Calico Pod ขึ้น..."
# watch kubectl get pods -n calico-system

echo "✅ Calico ติดตั้งเสร็จเรียบร้อย!"
